# TicketBridge

**TicketBridge** is a lightweight, API-first ticket management service.  
Usecase: Instead of integrating a full SDK into your application, you can simply send
HTTP requests to manage your support tickets.  

Powered by the **Elixir** ecosystem and the **BEAM** virtual machine.

---

## Features

- **API-first design** – Send tickets via simple HTTP POST requests.
- **No SDK required** – Integrate with any language or platform.
- **Web UI** – Manage tickets, view details, and update statuses.
- **API Token Management** – Generate and manage tokens directly from the UI.
- **Rate Limiting** – Built-in request throttling for stability.
- **Powered by Elixir & Phoenix** – High performance and fault tolerance.

---

## Tech Stack

- **Language:** Elixir
- **Framework:** Phoenix + LiveView
- **Runtime:** BEAM Virtual Machine
- **DB:** PostgreSQL

---

## 📦 Installation

> **Prerequisite:** You must have [Elixir](https://elixir-lang.org/install.html)
> installed.

Clone the repository:

```bash
git clone https://github.com/AndryTafa/ticket_bridge_elixir.git
cd ticket_bridge_elixir
```

Install dependencies:

```bash
mix deps.get
```

Set up the database:

```bash
mix ecto.setup
```

Start the Phoenix server:

```bash
mix phx.server
```

The app will be available at:  
[http://localhost:4000](http://localhost:4000)

---

##  Usage

TicketBridge has **two main components**:

1. **API Layer** – Send tickets into the system.
2. **UI Layer** – Log in to manage tickets and generate API tokens.

### 1️⃣ Sending Tickets via API

First, log in to the UI and generate an **API token**.  
Then, send a POST request to the API endpoint:

```bash
curl -X POST https://localhost:4000/api/tickets \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "subject": "Test Ticket",
    "message": "This is a test ticket",
    "priority": "high",
    "category": "support"
  }'
```

### 2️⃣ Managing Tickets via UI

- Log in to the web interface.
- View, update, and close tickets.
- Generate and revoke API tokens.

---

