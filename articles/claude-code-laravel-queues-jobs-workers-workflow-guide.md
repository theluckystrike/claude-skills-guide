---

layout: default
title: "Claude Code Laravel Queues, Jobs, Workers & Workflow Guide"
description: "Master Laravel queues, jobs, and workers with Claude Code. Learn to build asynchronous workflows, process background tasks, and handle job dispatching."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-laravel-queues-jobs-workers-workflow-guide/
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills]
---

{% raw %}

# Claude Code Laravel Queues, Jobs, Workers & Workflow Guide

Building scalable Laravel applications requires effectively handling asynchronous tasks through queues, jobs, and workers. Claude Code can help you implement robust background processing workflows that improve application performance and user experience. This guide covers practical techniques for working with Laravel's queue system, from basic job creation to advanced worker management.

## Setting Up Laravel Queues with Claude Code

Before implementing queue-based workflows, ensure Claude Code understands your Laravel queue configuration. Create a comprehensive CLAUDE.md file that specifies your queue driver and connection details:

```
This Laravel application uses:
- Queue driver: Redis (via predis/predis)
- Horizon for queue monitoring
- Supervisor for worker process management
- PHP 8.2+ with Laravel 10+
```

### Configuring Queue Connections

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

### Basic Job Structure

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

### Dispatching Jobs

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

### Running Queue Workers

Start workers for different queues based on priority:

```bash
# Process default queue
php artisan queue:work redis --queue=default

# Process multiple queues with priority
php artisan queue:work redis --queue=high-priority,default,low-priority

# Supervisor configuration example
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

### Queue Monitoring with Horizon

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
# Install and publish Horizon
composer require laravel/horizon
php artisan vendor:publish --provider="Laravel\Horizon\HorizonServiceProvider"

# Start Horizon supervisor
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

Implement robust error handling and job retries:

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

## Best Practices for Queue-Based Systems

When building queue-based systems with Claude Code, follow these practical guidelines:

1. **Keep jobs single-purpose**: Each job should handle one specific task. This improves reliability and makes debugging easier.

2. **Implement proper timeouts**: Set realistic timeout values based on expected job duration. Use longer timeouts for batch processing jobs.

3. **Use dedicated queues**: Separate different job types into dedicated queues (emails, notifications, data processing) to prioritize critical tasks.

4. **Monitor queue health**: Set up Horizon or custom monitoring to track job success rates, processing times, and queue depths.

5. **Handle idempotency**: Design jobs to be safely retried by implementing idempotent operations. Use unique job IDs to prevent duplicate processing.

6. **Implement proper logging**: Add detailed logging in job classes to trace execution flow and troubleshoot issues.

## Conclusion

Laravel's queue system provides a powerful foundation for building asynchronous workflows. With Claude Code's assistance, you can rapidly implement robust job classes, configure worker supervision, and build complex chained workflows that scale with your application needs. Remember to monitor your queues in production and implement proper error handling to ensure reliable background task processing.

{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

