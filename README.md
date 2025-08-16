# 🎓 Tuition Escrow Module

This Move module implements a **tuition escrow system** on the Aptos blockchain. It allows a payer to deposit funds in installments, which are released to a payee (e.g., an educational institution) based on due dates, with support for grace periods and late penalties.

---

## 📦 Module: `escrow::tuition_escrow`

### 🔐 Struct: `Escrow`

Stores escrow details:
- `payee`: Recipient address
- `total_amount`: Total escrowed amount
- `installment_amount`: Amount per installment
- `due_dates`: Vector of due timestamps
- `grace_period`: Allowed delay before penalties apply
- `penalty_rate`: Penalty rate per day (in basis points)
- `paid_installments`: Table tracking paid installments
- `held_funds`: Funds held in escrow (`Coin<AptosCoin>`)

---

## 🚀 Entry Functions

### `create_escrow`

Initializes a new escrow contract.

**Parameters:**
- `account`: Signer creating the escrow
- `payee`: Recipient address
- `total_amount`: Total amount to be paid
- `num_installments`: Number of installments
- `start_due`: Timestamp for first due date
- `interval`: Time between installments
- `grace_period`: Allowed delay before penalties
- `penalty_rate`: Penalty rate per day (basis points)

---

### `pay_installment`

Allows a payer to submit an installment.

**Parameters:**
- `payer`: Signer paying the installment
- `escrow_addr`: Address of the escrow resource
- `installment_id`: Index of the installment
- `amount`: Amount paid

**Behavior:**
- Applies penalty if overdue
- Releases funds to payee if within grace period
- Marks installment as paid

---

### `claim_funds`

Allows the payee to claim any remaining funds.

**Parameters:**
- `payee`: Signer claiming the funds
- `escrow_addr`: Address of the escrow resource

---

## ⚠️ Error Codes

- `1001`: Insufficient payment amount
- `1002`: Unauthorized claim attempt

---

## 🛠️ Dependencies

- `aptos_framework::timestamp`
- `aptos_framework::coin`
- `aptos_framework::aptos_coin::AptosCoin`
- `aptos_std::table`
- `std::signer`
- `std::vector`

---

## 📚 Example Use Case

A student pays tuition in monthly installments. If they miss a due date, a penalty is applied. The institution can claim funds once installments are paid or overdue.

---

## 🧠 Author Notes

Designed for modularity and extensibility. Future enhancements could include:
- Support for multiple payees
- Refund mechanisms
- Event logging for transparency
