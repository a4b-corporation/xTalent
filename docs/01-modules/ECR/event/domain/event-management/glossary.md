# Glossary: Event Management
## ECR Domain | 2026-03-25

This glossary defines the ubiquitous language for the Event Management bounded context. Terms defined here apply precisely within this context; the same word may carry a different meaning in another bounded context.

---

| Term | Definition | Notes / Disambiguations |
|------|-----------|------------------------|
| **Event** | The primary organizing entity of the ECR module. Represents a scheduled mass recruitment activity with a defined date range, one or more Tracks, a Registration Form, and a lifecycle state. | Not a calendar event or a domain event (messaging primitive). In this context, "Event" always means the recruitment event aggregate. Domain events (messaging) are referred to as "domain events" in full. |
| **Track** | A named pipeline configuration within an Event, representing a distinct job family or role category. Each Track has its own capacity, schedule slots, and pipeline stages. | Not a synonym for "phase" or "step." A Track organizes candidates by role type. An Event must have at least one Track before it can be Published. Tracks do not have sub-tracks. |
| **EventPhase** | A value object that describes the operational context of the Event's current lifecycle state. Used to determine which operations are permitted. | Distinct from lifecycle State. State is the technical transition label (e.g., `IN_PROGRESS`). Phase is the human-readable operational context (e.g., "Onsite Day"). Phase is derived from State, not independently assigned. |
| **RegistrationForm** | An entity that defines the schema of fields presented to candidates during registration. Belongs to a specific Event. Contains field definitions, validation rules, and field ordering. | Not a generic form builder. A RegistrationForm is always scoped to one Event. It cannot be shared across Events — cloning an Event copies the form schema by value. |
| **State Machine** | The formal model governing Event lifecycle transitions. States: Draft → Published → Registration Open → In Progress → Closed → Archived. Each transition has guards that must be satisfied. | "Structural immutability" refers specifically to the In Progress state transition guard: once entered, structural mutations are rejected. This is enforced by the Event aggregate, not by the database. |
| **Structural Mutation** | Any change to an Event's configuration that affects candidate capacity, pipeline stages, or data capture schema. Specifically: adding/removing Tracks, changing Track capacity, modifying RegistrationForm schema. | Contrast with "Operational Mutation": individual schedule adjustments, status updates, score entries — these remain permitted In Progress. BR-06 defines the exact boundary. |
| **Event Clone** | A new Event created by copying all structural data (tracks, capacities, form schema, schedule blueprint) from an existing Event by value. The clone has no runtime dependency on the source. | Clone is always copy-by-value, never copy-by-reference. The `EventCloned` domain event records the source event ID for traceability only. The clone is an independent aggregate from the moment of creation. |
| **Blueprint** | In the Event Management context: the structural template data captured at clone time — the combination of tracks, form schema, and schedule configuration. | "Blueprint" in the Assessment context means something different (an assessment template). When discussing Event cloning, always use "Event Blueprint" to disambiguate. |
| **Track Capacity** | The maximum number of candidates that can be confirmed in a given Track. Defined at Track creation, modifiable before In Progress, locked after. | Capacity is a Track-level concept, not a Room-level concept in this context. Room capacity is managed by the Schedule & Capacity BC. Track capacity sets the upper bound for how many slots can be allocated for that Track. |
| **Published Language** | The set of domain events emitted by Event Management that all other bounded contexts consume. Events include: EventPublished, RegistrationOpened, EventStarted, TrackAdded, EventClosed, EventArchived, EventCloned. | Event Management is the upstream publisher. All downstream contexts are conformist consumers of this language. No downstream context may modify the event schema without Event Management's agreement. |
| **Transition Guard** | A precondition that must be true before a lifecycle state transition is permitted. Guards are enforced by the Event aggregate root, not by external services. | Examples: `Publish` guard requires >= 1 Track. `StartEvent` guard requires event date is today or past. Guards are documented in the State Machine specification, not in application services. |
| **Job Requisition Link** | A reference from a Track to an xTalent Job Request ID. Established via the xTalent Job Request API. Optional — not all tracks require a linked requisition in the MVP. | This is the integration point between Event Management and the upstream xTalent HCM platform. A Track may exist without a Job Requisition Link during early event setup. |

---

## Business Rules in This Context

| BR-ID | Rule | Domain Impact |
|-------|------|--------------|
| BR-06 | Structural immutability once In Progress | Event aggregate rejects structural mutation commands after `EventStarted` is emitted |

## Lifecycle State Reference

| State | Description | Entry Guard | Permitted Operations |
|-------|-------------|-------------|---------------------|
| Draft | Event created, not yet visible | None | All structural mutations permitted |
| Published | Event visible to candidates | >= 1 Track, valid date range, RegistrationForm defined | Structural mutations permitted |
| Registration Open | Candidates may register | Event date is in the future | Registration commands accepted |
| In Progress | Event is actively running | Event date has arrived | Structural mutations BLOCKED; operational mutations permitted |
| Closed | Event concluded | Event date has passed or TA override | Read-only (report access) |
| Archived | Event stored for historical reference | Must be Closed first | Read-only (audit access) |
