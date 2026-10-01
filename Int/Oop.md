# OOP + SOLID Interview Cheat Sheet

## 1. OOP — 4 Core Principles

### 1. Encapsulation

**Bundle data + behavior together and control access to internal state.**

```csharp
public class BankAccount
{
    private decimal _balance;

    public void Deposit(decimal amount)
    {
        if (amount <= 0)
            throw new ArgumentException();

        _balance += amount;
    }

    public decimal GetBalance() => _balance;
}
```

Key idea:

```text
Don't expose internal state unnecessarily.
Expose behavior instead.
```

**Interview phrase:**

> Encapsulation protects an object's invariants by controlling how its internal state is accessed or modified.

---

## 2. Abstraction

**Expose what an object does, hide how it does it.**

```csharp
public interface IPaymentService
{
    Task PayAsync(decimal amount);
}
```

Implementation:

```csharp
public class StripePaymentService : IPaymentService
{
    public Task PayAsync(decimal amount)
    {
        // Stripe implementation
    }
}
```

Consumer only knows:

```text
IPaymentService
      ↓
PayAsync()
```

It doesn't need to know the implementation details.

### Encapsulation vs Abstraction

| Encapsulation                    | Abstraction                     |
| -------------------------------- | ------------------------------- |
| Hides internal state/details     | Hides implementation complexity |
| Controls access                  | Defines essential behavior      |
| `private` fields                 | Interfaces/abstract classes     |
| Focus: **how data is protected** | Focus: **what is exposed**      |

---

# 3. Inheritance

A child class derives behavior from a parent class.

```csharp
public class Animal
{
    public void Eat() { }
}

public class Dog : Animal
{
    public void Bark() { }
}
```

```text
Animal
  ↑
 Dog
```

Relationship:

> **IS-A**

```text
Dog IS-A Animal
```

### Don't overuse inheritance

Prefer composition when the relationship isn't genuinely hierarchical.

---

# 4. Polymorphism

**Same interface/base type, different behavior.**

```csharp
public interface INotification
{
    void Send(string message);
}

public class EmailNotification : INotification
{
    public void Send(string message)
        => Console.WriteLine("Email");
}

public class SmsNotification : INotification
{
    public void Send(string message)
        => Console.WriteLine("SMS");
}
```

```csharp
INotification notification = new EmailNotification();
notification.Send("Hello");
```

The actual implementation is determined at runtime.

### Types of polymorphism

```text
Compile-time
   ↓
Method overloading

Runtime
   ↓
Method overriding / interface implementation
```

---

# 5. Composition

Build objects using other objects.

```csharp
public class OrderService
{
    private readonly IPaymentService _paymentService;

    public OrderService(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }
}
```

```text
OrderService
     │
     └── uses → IPaymentService
```

Relationship:

> **HAS-A / USES-A**

### Composition vs inheritance

```text
Inheritance:
Dog IS-A Animal

Composition:
Order HAS-A PaymentService
```

**Interview rule:**

> Favor composition over inheritance when behavior can be composed rather than inherited.

---

# 6. Class vs Abstract Class vs Interface

|                      | Class           | Abstract Class          | Interface                        |
| -------------------- | --------------- | ----------------------- | -------------------------------- |
| Can instantiate?     | ✅               | ❌                       | ❌                                |
| Implementation       | ✅               | ✅                       | Can have default implementations |
| Fields               | ✅               | ✅                       | No instance fields               |
| Constructor          | ✅               | ✅                       | ❌                                |
| Multiple inheritance | ❌               | ❌                       | Multiple interfaces              |
| Main purpose         | Concrete object | Shared base abstraction | Contract                         |

### Use abstract class when

Classes share:

* Common state
* Common implementation
* Strong parent-child relationship

### Use interface when

You primarily need:

* A contract
* Loose coupling
* Dependency injection
* Multiple implementations

---

# SOLID

```text
S → Single Responsibility
O → Open/Closed
L → Liskov Substitution
I → Interface Segregation
D → Dependency Inversion
```

---

# 7. S — Single Responsibility Principle

> **A class should have one reason to change.**

Bad:

```csharp
class InvoiceService
{
    CalculateInvoice();
    SaveToDatabase();
    SendEmail();
    GeneratePdf();
}
```

Multiple responsibilities:

```text
Invoice calculation
Database persistence
Email
PDF generation
```

Better:

```text
InvoiceCalculator
InvoiceRepository
EmailService
InvoicePdfGenerator
```

### Important interview clarification

SRP does **not** mean:

> "Every class should contain only one method."

It means:

> A class should have one cohesive responsibility / one reason to change.

---

# 8. O — Open/Closed Principle

> **Software entities should be open for extension but closed for modification.**

Bad:

```csharp
public decimal CalculateDiscount(Customer customer)
{
    if (customer.Type == "Gold")
        return 20;

    if (customer.Type == "Silver")
        return 10;

    if (customer.Type == "Bronze")
        return 5;

    return 0;
}
```

Every new customer type requires modifying this class.

Better:

```csharp
public interface IDiscountStrategy
{
    decimal Calculate(Customer customer);
}
```

```text
IDiscountStrategy
      │
      ├── GoldDiscount
      ├── SilverDiscount
      └── BronzeDiscount
```

Add a new strategy without modifying existing strategies.

### Common implementation

**Strategy Pattern**

---

# 9. L — Liskov Substitution Principle

> **A derived type must be substitutable for its base type without breaking expected behavior.**

Classic example:

```text
Bird
 ├── Sparrow
 └── Penguin
```

If base class says:

```csharp
bird.Fly();
```

then `Penguin : Bird` violates the abstraction because penguins don't fly.

Better:

```text
Bird
  │
  ├── Sparrow → FlyingBird
  │
  └── Penguin → NonFlyingBird
```

### Practical test

Ask:

> "Can I replace the parent/base type with this child without surprising the caller?"

If **no**, LSP is probably violated.

### Common LSP violation

```csharp
public class ReadOnlyRepository : IRepository
{
    public void Add(Entity entity)
    {
        throw new NotSupportedException();
    }
}
```

If `IRepository` promises `Add()`, an implementation that fundamentally cannot support it may violate substitutability.

---

# 10. I — Interface Segregation Principle

> **Clients should not be forced to depend on methods they don't use.**

Bad:

```csharp
public interface IWorker
{
    void Work();
    void Eat();
}
```

A robot doesn't need `Eat()`.

Better:

```csharp
public interface IWorkable
{
    void Work();
}

public interface IEatable
{
    void Eat();
}
```

Now:

```text
Human
 ├── IWorkable
 └── IEatable

Robot
 └── IWorkable
```

### Interview phrase

> Prefer several small, focused interfaces over one large "fat" interface.

---

# 11. D — Dependency Inversion Principle

> **High-level modules should not depend directly on low-level implementation details. Both should depend on abstractions.**

Bad:

```csharp
public class OrderService
{
    private readonly SqlOrderRepository _repository;

    public OrderService()
    {
        _repository = new SqlOrderRepository();
    }
}
```

`OrderService` is tightly coupled to SQL implementation.

Better:

```csharp
public class OrderService
{
    private readonly IOrderRepository _repository;

    public OrderService(IOrderRepository repository)
    {
        _repository = repository;
    }
}
```

```text
        IOrderRepository
             ↑
      ┌──────┴──────┐
      │             │
SqlRepository   MongoRepository
      ↑
      │
OrderService
```

This enables:

* Testing
* Replaceability
* Loose coupling
* Different implementations

---

# 12. DIP vs Dependency Injection

This is a **very common interview question**.

### Dependency Inversion Principle

A **design principle**:

```text
High-level
    ↓
Abstraction
    ↑
Low-level
```

### Dependency Injection

A **technique** for supplying dependencies from outside.

```csharp
public OrderService(IOrderRepository repository)
{
    _repository = repository;
}
```

So:

```text
DIP = Principle
DI  = Technique
```

DI helps you implement DIP, but they are not the same thing.

---

# 13. SOLID — One Example

Suppose you have:

```csharp
class OrderService
{
    public void CreateOrder()
    {
        // validation
        // calculate price
        // save to SQL
        // send email
        // generate PDF
    }
}
```

Problems:

```text
SRP → Too many responsibilities

OCP → Adding behavior requires modifying class

DIP → Direct SQL dependency

ISP → Potentially large service interfaces

LSP → Can be violated by inappropriate inheritance
```

Refactor:

```text
                 OrderService
                      │
       ┌──────────────┼──────────────┐
       ↓              ↓              ↓
IOrderRepository IEmailService IOrderCalculator
       │              │              │
       ↓              ↓              ↓
 SQL Repository   Email Service   Calculator
```

Now:

```text
OrderService
     ↓
Interfaces
     ↓
Implementations
```

---

# 14. SOLID + Design Patterns

Know these relationships:

| SOLID | Common patterns               |
| ----- | ----------------------------- |
| SRP   | Facade, Command               |
| OCP   | Strategy, Decorator           |
| LSP   | Proper polymorphism           |
| ISP   | Adapter, focused interfaces   |
| DIP   | Dependency Injection, Factory |

Don't memorize the mapping as absolute rules. Patterns can help achieve SOLID principles, but one pattern doesn't automatically make code SOLID.

---

# 15. SOLID in ASP.NET Core

A very good interview example:

```csharp
public interface IOrderRepository
{
    Task<Order?> GetAsync(int id);
    Task SaveAsync(Order order);
}
```

```csharp
public class OrderService
{
    private readonly IOrderRepository _repository;

    public OrderService(IOrderRepository repository)
    {
        _repository = repository;
    }
}
```

Register:

```csharp
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
```

Architecture:

```text
Controller
    ↓
OrderService
    ↓
IOrderRepository
    ↑
OrderRepository
    ↓
EF Core
    ↓
Database
```

This demonstrates:

* **DIP** → Service depends on abstraction
* **DI** → Dependency supplied by ASP.NET Core
* **SRP** → Each layer has focused responsibility
* **OCP** → Repository implementation can be replaced
* **ISP** → Small repository interface

---

# 16. OOP Interview Rapid-Fire

### What is encapsulation?

Hiding internal state and controlling access through well-defined methods/properties.

### What is abstraction?

Hiding implementation details while exposing essential behavior.

### What is inheritance?

Deriving a class from another class to reuse/extend behavior.

### What is polymorphism?

Allowing different implementations to be treated through a common abstraction.

### Composition vs inheritance?

> Composition represents **HAS-A/USES-A**; inheritance represents **IS-A**.

### What is SOLID?

Five principles for designing maintainable, loosely coupled, extensible object-oriented software.

### Which SOLID principle is about "one reason to change"?

**SRP**

### Which says "open for extension, closed for modification"?

**OCP**

### Which prevents problematic inheritance?

**LSP**

### Which prevents fat interfaces?

**ISP**

### Which promotes abstraction over concrete dependencies?

**DIP**

### DIP vs DI?

**DIP is a principle; DI is a technique.**

---

# 17. The 30-Second Interview Answer

If they ask **"Explain OOP and SOLID"**, you can answer:

> "The four fundamental OOP concepts are encapsulation, abstraction, inheritance and polymorphism. Encapsulation protects an object's state, abstraction exposes essential behavior while hiding implementation details, inheritance allows specialization through an IS-A relationship, and polymorphism allows different implementations to be used through a common abstraction.
>
> SOLID builds on these concepts. SRP means a class should have one reason to change. OCP means we should be able to extend behavior without modifying existing code. LSP means derived types should be substitutable for their base types. ISP says clients shouldn't depend on methods they don't need. DIP says high-level business logic should depend on abstractions rather than concrete infrastructure implementations. In ASP.NET Core, dependency injection is commonly used to implement DIP."

### One mental model to memorize

```text
OOP
│
├── Encapsulation → Protect state
├── Abstraction   → Hide complexity
├── Inheritance   → IS-A
└── Polymorphism  → Many implementations
             │
             ↓
          SOLID
             │
├── S → One responsibility
├── O → Extend, don't modify
├── L → Subtypes must substitute
├── I → Small focused interfaces
└── D → Depend on abstractions
```

**For your JD specifically, focus hardest on `DIP + DI`, `OCP + Strategy`, `LSP`, composition vs inheritance, and applying SOLID to a .NET 8 microservice/Clean Architecture.**
