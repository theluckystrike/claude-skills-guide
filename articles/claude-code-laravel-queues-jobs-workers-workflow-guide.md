---

layout: default
title: "Claude Code Laravel Queues, Jobs, Workers & Workflow Guide"
description: "Master Laravel queues, jobs, and workers with Claude Code. Learn to build asynchronous workflows, process background tasks, and handle job dispatching."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-laravel-queues-jobs-workers-workflow-guide/
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills]
geo_optimized: true
---



Building scalable Laravel applications requires effectively handling asynchronous tasks through queues, jobs, and workers. Claude Code can help you implement solid background processing workflows that improve application performance and user experience. This guide covers practical techniques for working with Laravel's queue system, from basic job creation to advanced worker management.

## Setting Up Laravel Queues with Claude Code

Before implementing queue-based workflows, ensure Claude Code understands your Laravel queue configuration. Create a comprehensive CLAUDE.md file that specifies your queue driver and connection details:

```
This Laravel application uses:
- Queue driver: Redis (via predis/predis)
- Horizon for queue monitoring
- Supervisor for worker process management
- PHP 8.2+ with Laravel 10+
```

## Configuring Queue Connections

Laravel supports multiple queue drivers including Redis, Database, SQS, and RabbitMQ. Here's how to configure a Redis-backed queue using Claude Code:

```php
// config/queue.php - Connection configuration
'connections' => [
 'redis' => [
 'driver' => 'redis',
 'connection' => 'default',
 'queue' => env('REDIS_QUEUE', 'default'),
 'retry_after' => 90,
 'block_for' => null,
 ],
 
 'redis-high-priority' => [
 'driver' => 'redis',
 'connection' => 'default',
 'queue' => 'high-priority',
 'retry_after' => 60,
 ],
],
```

## Creating Jobs with Claude Code

Laravel jobs encapsulate the logic for asynchronous task processing. Claude Code can help you generate well-structured jobs with proper error handling, retries, and event handling.

## Basic Job Structure

Here's a typical job class for sending welcome emails:

```php
<?php

namespace App\Jobs;

use App\Models\User;
use App\Mail\WelcomeMail;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendWelcomeEmail implements ShouldQueue
{
 use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

 public int $tries = 3;
 public int $backoff = 60;
 public int $timeout = 120;

 public function __construct(
 public User $user
 ) {}

 public function handle(): void
 {
 Mail::to($user->email)->send(new WelcomeMail($this->user));
 }

 public function failed(\Throwable $exception): void
 {
 // Log failure or notify administrators
 \Log::error("Welcome email failed for user {$this->user->id}", [
 'error' => $exception->getMessage(),
 ]);
 }
}
```

## Dispatching Jobs

You can dispatch jobs synchronously or asynchronously:

```php
// Asynchronous dispatch (uses queue)
SendWelcomeEmail::dispatch($user)->onQueue('emails');

// Delayed dispatch
SendWelcomeEmail::dispatch($user)->delay(now()->addMinutes(10));

// Chain multiple jobs
Bus::chain([
 new ProcessUserRegistration($user),
 new SendWelcomeEmail($user),
 new AssignDefaultRoles($user),
])->dispatch();

// Batch processing
$users = User::whereNull('welcome_sent_at')->get();
SendWelcomeEmail::batch($users)->dispatch();
```

## Worker Management and Supervision

Laravel workers process jobs from the queue. For production environments, you need proper worker supervision using Supervisor or similar process managers.

## Running Queue Workers

Start workers for different queues based on priority:

```bash
Process default queue
php artisan queue:work redis --queue=default

Process multiple queues with priority
php artisan queue:work redis --queue=high-priority,default,low-priority

Supervisor configuration example
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan queue:work redis --queue=high-priority,default --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/log/laravel-worker.log
stopwaitsecs=3600
```

## Queue Monitoring with Horizon

Laravel Horizon provides a powerful dashboard for monitoring queues:

```php
// app/Providers/HorizonServiceProvider.php
public function boot(): void
{
 parent::boot();

 Horizon::routeMailNotificationsTo('admin@example.com');
 Horizon::routeSlackNotificationsTo('webhook-url', '#deployments');
 Horizon::routeSmsNotificationsTo('+1234567890');
}
```

```bash
Install and publish Horizon
composer require laravel/horizon
php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider"

Start Horizon supervisor
php artisan horizon
```

## Building Workflows with Chained Jobs

For complex business processes, you can chain jobs together to create reliable workflows:

```php
class ProcessOrderWorkflow
{
 public static function run(Order $order): void
 {
 Bus::chain([
 new ValidateOrderJob($order),
 new ReserveInventoryJob($order),
 new ProcessPaymentJob($order),
 new CreateShippingLabelJob($order),
 new NotifyCustomerJob($order),
 ])->catch(function ($chain, $e) {
 // Rollback logic on failure
 new RollbackOrderJob($order, $e->getMessage())->dispatch();
 })->dispatch();
 }
}
```

## Handling Failed Jobs

Implement solid error handling and job retries:

```php
class ProcessPaymentJob implements ShouldQueue
{
 public int $tries = 5;
 public array $backoff = [30, 60, 120, 300, 600];
 public int $maxExceptions = 3;

 public function handle(PaymentService $payments): void
 {
 try {
 $payments->process($this->order->total);
 } catch (PaymentDeclinedException $e) {
 // Don't retry for declined cards
 throw new \RuntimeException('Payment declined: ' . $e->getMessage());
 } catch (PaymentGatewayException $e) {
 // Retry for gateway errors
 throw $e;
 }
 }

 public function retryUntil(): \DateTime
 {
 return now()->addDays(7);
 }
}
```

## Using Job Batches for Parallel Processing

When you need to process a large collection of items in parallel and then react when the entire batch completes, Laravel's batch system is the right tool. Claude Code can scaffold the batch dispatch and callback structure for you in seconds.

```php
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;
use Throwable;

class ImportProductCatalog
{
 public function handle(array $productChunks): void
 {
 $jobs = collect($productChunks)->map(
 fn ($chunk) => new ImportProductChunkJob($chunk)
 )->all();

 Bus::batch($jobs)
 ->then(function (Batch $batch) {
 // All jobs completed successfully
 \Log::info("Product import complete. Processed {$batch->totalJobs} chunks.");
 event(new CatalogImportCompleted($batch->id));
 })
 ->catch(function (Batch $batch, Throwable $e) {
 // First job failure detected
 \Log::error("Catalog import batch failed: {$e->getMessage()}", [
 'batch_id' => $batch->id,
 'failed_jobs' => $batch->failedJobs,
 ]);
 event(new CatalogImportFailed($batch->id));
 })
 ->finally(function (Batch $batch) {
 // Runs regardless of success or failure
 CatalogImport::where('batch_id', $batch->id)
 ->update(['finished_at' => now()]);
 })
 ->name('Product Catalog Import')
 ->allowFailures()
 ->dispatch();
 }
}
```

The `allowFailures()` call lets the batch continue processing remaining jobs even when some fail. This is the right default for import pipelines where one bad record should not abort thousands of valid ones. Remove it for financial workflows where partial completion is worse than a full rollback.

To track batch progress from a controller or API endpoint:

```php
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;

public function importStatus(string $batchId): JsonResponse
{
 $batch = Bus::findBatch($batchId);

 if (! $batch) {
 return response()->json(['error' => 'Batch not found'], 404);
 }

 return response()->json([
 'id' => $batch->id,
 'name' => $batch->name,
 'total_jobs' => $batch->totalJobs,
 'pending_jobs' => $batch->pendingJobs,
 'failed_jobs' => $batch->failedJobs,
 'progress' => $batch->progress(),
 'finished' => $batch->finished(),
 'cancelled' => $batch->cancelled(),
 ]);
}
```

## Rate Limiting and Throttling Jobs

Some external APIs enforce rate limits that your queue workers must respect. Laravel provides a `RateLimiter`-based approach that works directly inside job classes, preventing excessive calls without complex external coordination.

```php
use Illuminate\Queue\Middleware\RateLimited;

class SyncContactToHubspot implements ShouldQueue
{
 use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

 public int $tries = 10;

 public function __construct(
 public readonly int $contactId
 ) {}

 public function middleware(): array
 {
 return [new RateLimited('hubspot-api')];
 }

 public function handle(HubspotClient $client): void
 {
 $contact = Contact::findOrFail($this->contactId);
 $client->upsertContact($contact->toHubspotPayload());
 }
}
```

Register the limiter in a service provider:

```php
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

RateLimiter::for('hubspot-api', function () {
 // HubSpot allows 100 requests per 10 seconds per app
 return Limit::perSeconds(10, 100);
});
```

When a job hits the rate limit, Laravel automatically releases it back onto the queue and retries after the window expires. You do not need to write any retry logic yourself. Claude Code can generate this pattern for any third-party API by asking it: "scaffold a throttled job for the [service] API respecting [N] requests per [period]."

## Testing Queue Jobs Locally

Debugging jobs in production is painful. Set up a proper local testing workflow from day one. The `Queue::fake()` helper lets you assert job dispatches without actually running workers.

```php
use App\Jobs\SendWelcomeEmail;
use Illuminate\Support\Facades\Queue;

class UserRegistrationTest extends TestCase
{
 public function test_welcome_email_job_is_dispatched_after_registration(): void
 {
 Queue::fake();

 $response = $this->postJson('/api/register', [
 'name' => 'Alice',
 'email' => 'alice@example.com',
 'password' => 'secret-password-123',
 ]);

 $response->assertCreated();

 Queue::assertPushed(SendWelcomeEmail::class, function ($job) {
 return $job->user->email === 'alice@example.com';
 });

 Queue::assertNotPushed(\App\Jobs\SendAdminAlert::class);
 }
}
```

For integration tests where you want the job to actually execute, use `Queue::fake()` with `Bus::dispatchSync()` or switch to the `sync` queue driver in your `phpunit.xml` environment config:

```xml
<env name="QUEUE_CONNECTION" value="sync"/>
```

With `sync`, every dispatched job runs immediately in the same process, so you can assert on the side effects (database records written, emails sent) rather than just the dispatch itself. Reserve this for tests that are explicitly checking job behavior end-to-end, not for unit tests of controllers or services.

## Debugging Stuck or Failed Jobs

When jobs start piling up or failing silently, the first place to look is the `failed_jobs` table. Run this Artisan command to list recent failures with their exception messages:

```bash
php artisan queue:failed
```

To retry all failed jobs at once:

```bash
php artisan queue:retry all
```

To inspect a single failure before retrying:

```bash
php artisan queue:failed --id=12345
```

For jobs that appear to be processing but never complete, check the `retry_after` value in `config/queue.php`. If a job takes longer than `retry_after` seconds, Laravel assumes the worker died and re-queues the job, which can produce duplicate processing. Always set `retry_after` to at least 30 seconds more than your job's expected worst-case runtime.

Horizon gives you a live view of this data. The "Metrics" tab shows throughput and runtime averages per queue and per job class, which makes it easy to spot a job that normally takes 2 seconds suddenly averaging 45 seconds, a sign of an upstream dependency degrading.

## Best Practices for Queue-Based Systems

When building queue-based systems with Claude Code, follow these practical guidelines:

1. Keep jobs single-purpose: Each job should handle one specific task. This improves reliability and makes debugging easier.

2. Implement proper timeouts: Set realistic timeout values based on expected job duration. Use longer timeouts for batch processing jobs.

3. Use dedicated queues: Separate different job types into dedicated queues (emails, notifications, data processing) to prioritize critical tasks.

4. Monitor queue health: Set up Horizon or custom monitoring to track job success rates, processing times, and queue depths.

5. Handle idempotency: Design jobs to be safely retried by implementing idempotent operations. Use unique job IDs to prevent duplicate processing.

6. Implement proper logging: Add detailed logging in job classes to trace execution flow and troubleshoot issues.

## Conclusion

Laravel's queue system provides a powerful foundation for building asynchronous workflows. With Claude Code's assistance, you can rapidly implement solid job classes, configure worker supervision, and build complex chained workflows that scale with your application needs. Remember to monitor your queues in production and implement proper error handling to ensure reliable background task processing.



---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-laravel-queues-jobs-workers-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Cloudflare Workers KV Workflow](/claude-code-for-cloudflare-workers-kv-workflow/)
- [Claude Code for Web Workers Workflow Guide](/claude-code-for-web-workers-workflow-guide/)
- [Claude Skills for PHP Laravel Development Workflow](/claude-skills-for-php-laravel-development-workflow/)
- [Claude Code Laravel Livewire Real-Time Workflow Tutorial](/claude-code-laravel-livewire-real-time-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


