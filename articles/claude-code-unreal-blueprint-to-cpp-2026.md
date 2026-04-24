---
title: "Claude Code for Unreal Blueprint to C++"
permalink: /claude-code-unreal-blueprint-to-cpp-2026/
description: "Convert Unreal Engine Blueprints to C++ with Claude Code. Optimize gameplay logic, expose properties to editor, and maintain Blueprint compatibility."
last_tested: "2026-04-22"
domain: "game development"
render_with_liquid: false
---

## Why Claude Code for Blueprint to C++ Conversion

Unreal Engine Blueprints are excellent for prototyping, but production games need C++ for performance-critical systems: AI behavior trees, procedural generation, physics calculations, and networking. A single Blueprint tick running complex logic on 100 actors can drop frame rates below acceptable levels. The conversion requires understanding Unreal's reflection system (UPROPERTY, UFUNCTION), the gameplay framework hierarchy (AActor, UActorComponent, ACharacter), and how to maintain Blueprint extensibility from C++ base classes.

Claude Code generates UE5 C++ code with proper Unreal macros, specifiers, and patterns that integrate seamlessly with the editor. It converts Blueprint node graphs into equivalent C++ while preserving the ability for designers to override behavior in Blueprint subclasses.

## The Workflow

### Step 1: Analyze Blueprint Complexity

```bash
# Find large Blueprints that need conversion (by file size)
find /path/to/project/Content -name "*.uasset" -size +1M | sort -rn

# Use Unreal's Blueprint audit commandlet
UE5Editor "MyProject.uproject" -run=CompileAllBlueprints -log

# Check Blueprint nativization report
UE5Editor "MyProject.uproject" -run=NativizeBP -log
```

### Step 2: Convert Character Blueprint to C++

Blueprint logic (conceptual):

```
Event Tick:
  -> Get Movement Input Axis
  -> Calculate Movement Vector
  -> Check Is Sprinting (boolean)
  -> If Sprinting: multiply speed by 2
  -> Add Movement Input
  -> Update Stamina (decrease if sprinting)
  -> If Stamina <= 0: Stop Sprinting

Custom Event: TakeDamage
  -> Subtract Health
  -> If Health <= 0: Die()
  -> Else: Play Hit Reaction Montage
  -> Update Health Bar Widget
```

Claude Code generates the C++ equivalent:

```cpp
// MyCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "MyCharacter.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealthChanged, float, NewHealth);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnCharacterDied);

UCLASS(Blueprintable)
class MYGAME_API AMyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AMyCharacter();

    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(UInputComponent* InputComp) override;

    // Exposed to Blueprint for designer tuning
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Movement")
    float WalkSpeed = 600.f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Movement")
    float SprintMultiplier = 2.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stamina")
    float MaxStamina = 100.f;

    UPROPERTY(BlueprintReadOnly, Category = "Stamina")
    float CurrentStamina;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stamina")
    float StaminaDrainRate = 20.f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stamina")
    float StaminaRegenRate = 10.f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Health")
    float MaxHealth = 100.f;

    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Health, Category = "Health")
    float CurrentHealth;

    // Blueprint-callable functions
    UFUNCTION(BlueprintCallable, Category = "Combat")
    void ApplyDamage(float DamageAmount, AActor* DamageCauser);

    UFUNCTION(BlueprintNativeEvent, Category = "Combat")
    void Die();

    // Blueprint-assignable delegates
    UPROPERTY(BlueprintAssignable, Category = "Health")
    FOnHealthChanged OnHealthChanged;

    UPROPERTY(BlueprintAssignable, Category = "Health")
    FOnCharacterDied OnCharacterDied;

protected:
    UPROPERTY(BlueprintReadOnly, Category = "Movement")
    bool bIsSprinting = false;

    UPROPERTY(EditDefaultsOnly, Category = "Animation")
    UAnimMontage* HitReactionMontage;

    virtual void BeginPlay() override;
    virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutProps) const override;

private:
    void HandleMovement(float DeltaTime);
    void HandleStamina(float DeltaTime);

    UFUNCTION()
    void OnRep_Health();

    // Input handlers
    void MoveForward(float Value);
    void MoveRight(float Value);
    void StartSprint();
    void StopSprint();
};
```

```cpp
// MyCharacter.cpp
#include "MyCharacter.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Net/UnrealNetwork.h"

AMyCharacter::AMyCharacter()
{
    PrimaryActorTick.bCanEverTick = true;
    CurrentStamina = MaxStamina;
    CurrentHealth = MaxHealth;
}

void AMyCharacter::BeginPlay()
{
    Super::BeginPlay();
    CurrentStamina = MaxStamina;
    CurrentHealth = MaxHealth;
    GetCharacterMovement()->MaxWalkSpeed = WalkSpeed;
}

void AMyCharacter::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
    HandleMovement(DeltaTime);
    HandleStamina(DeltaTime);
}

void AMyCharacter::HandleMovement(float DeltaTime)
{
    const float TargetSpeed = bIsSprinting ? WalkSpeed * SprintMultiplier : WalkSpeed;
    GetCharacterMovement()->MaxWalkSpeed = FMath::FInterpTo(
        GetCharacterMovement()->MaxWalkSpeed, TargetSpeed, DeltaTime, 10.f
    );
}

void AMyCharacter::HandleStamina(float DeltaTime)
{
    if (bIsSprinting && GetVelocity().Size() > 10.f)
    {
        CurrentStamina = FMath::Max(0.f, CurrentStamina - StaminaDrainRate * DeltaTime);
        if (CurrentStamina <= 0.f)
        {
            StopSprint();
        }
    }
    else
    {
        CurrentStamina = FMath::Min(MaxStamina, CurrentStamina + StaminaRegenRate * DeltaTime);
    }
}

void AMyCharacter::ApplyDamage(float DamageAmount, AActor* DamageCauser)
{
    if (CurrentHealth <= 0.f) return;

    CurrentHealth = FMath::Max(0.f, CurrentHealth - DamageAmount);
    OnHealthChanged.Broadcast(CurrentHealth);

    if (CurrentHealth <= 0.f)
    {
        Die();
    }
    else if (HitReactionMontage)
    {
        PlayAnimMontage(HitReactionMontage);
    }
}

void AMyCharacter::Die_Implementation()
{
    OnCharacterDied.Broadcast();
    GetCharacterMovement()->DisableMovement();
    GetCapsuleComponent()->SetCollisionEnabled(ECollisionEnabled::NoCollision);
}

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutProps) const
{
    Super::GetLifetimeReplicatedProps(OutProps);
    DOREPLIFETIME(AMyCharacter, CurrentHealth);
}

void AMyCharacter::OnRep_Health()
{
    OnHealthChanged.Broadcast(CurrentHealth);
}

void AMyCharacter::StartSprint()
{
    if (CurrentStamina > 0.f)
    {
        bIsSprinting = true;
    }
}

void AMyCharacter::StopSprint()
{
    bIsSprinting = false;
}
```

### Step 3: Maintain Blueprint Compatibility

```cpp
// Use BlueprintNativeEvent for functions designers can override
UFUNCTION(BlueprintNativeEvent, Category = "Combat")
void OnHit(float Damage);

// Implementation suffix _Implementation required
void AMyCharacter::OnHit_Implementation(float Damage)
{
    // C++ default behavior
    ApplyDamage(Damage, nullptr);
}

// Designers can override OnHit in Blueprint subclasses
// without touching C++ code
```

### Step 4: Verify

```bash
# Build from command line
UE5Editor "MyProject.uproject" -build -target=MyProjectEditor

# Run automated tests
UE5Editor "MyProject.uproject" -ExecCmds="Automation RunTests MyProject" -log

# Profile to verify performance improvement
UE5Editor "MyProject.uproject" -ExecCmds="stat startfile" -game
```

## CLAUDE.md for Unreal C++ Development

```markdown
# Unreal Engine Blueprint to C++ Standards

## Domain Rules
- UPROPERTY with EditAnywhere for designer-tunable values
- UPROPERTY with BlueprintReadOnly for read-only runtime values
- UFUNCTION(BlueprintCallable) for functions designers can call
- UFUNCTION(BlueprintNativeEvent) for overridable behavior
- Use GENERATED_BODY() macro in every UCLASS/USTRUCT
- Replicated properties need GetLifetimeReplicatedProps and DOREPLIFETIME
- Tick-heavy logic must be profiled with stat startfile

## File Patterns
- Source/ModuleName/Public/*.h (headers)
- Source/ModuleName/Private/*.cpp (implementations)
- ModuleName.Build.cs (module dependencies)

## Common Commands
- UE5Editor Project.uproject -build
- UE5Editor Project.uproject -run=CompileAllBlueprints
- UE5Editor Project.uproject -ExecCmds="Automation RunTests"
- UnrealBuildTool -project=Project.uproject -target=Game Development Win64
```

## Common Pitfalls in Blueprint to C++ Conversion

- **Missing GENERATED_BODY():** Forgetting this macro in UCLASS causes cryptic compilation errors. Claude Code always includes it as the first line in every Unreal class body.

- **Hot reload corrupting Blueprint references:** Changing C++ base class properties can break Blueprint subclasses. Claude Code uses `BlueprintNativeEvent` and property specifiers that maintain Blueprint compatibility during iteration.

- **Tick performance not measured:** Converting Blueprint to C++ does not automatically improve performance if the logic itself is inefficient. Claude Code profiles before and after conversion to verify actual frame time improvement.

## Related

- [Claude Code for Godot GDScript Development](/claude-code-godot-gdscript-development-2026/)
- [Claude Code for Unity Shader Development](/claude-code-unity-hlsl-shader-development-2026/)
- [Claude Code for Blender Python Scripting](/claude-code-blender-python-scripting-2026/)
