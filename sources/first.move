module escrow::tuition_escrow {
    use aptos_framework::timestamp;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_std::table::{Self, Table};
    use std::signer;
    use std::vector;

    struct Escrow has key {
        payee: address,
        total_amount: u64,
        installment_amount: u64,
        due_dates: vector<u64>,
        grace_period: u64,
        penalty_rate: u64,
        paid_installments: Table<u64, bool>,
        held_funds: coin::Coin<AptosCoin>,
    }

    public entry fun create_escrow(
        account: &signer,
        payee: address,
        total_amount: u64,
        num_installments: u64,
        start_due: u64,
        interval: u64,
        grace_period: u64,
        penalty_rate: u64
    ) {
        let due_dates = vector::empty<u64>();
        let current_due = start_due;
        let i = 0;
        while (i < num_installments) {
            vector::push_back(&mut due_dates, current_due);
            current_due = current_due + interval;
            i = i + 1;
        };
        let installment_amount = total_amount / num_installments;
        
        move_to(account, Escrow {
            payee,
            total_amount,
            installment_amount,
            due_dates,
            grace_period,
            penalty_rate,
            paid_installments: table::new(),
            held_funds: coin::zero<AptosCoin>(),
        });
    }

    public entry fun pay_installment(
        payer: &signer,
        escrow_addr: address,
        installment_id: u64,
        amount: u64
    ) acquires Escrow {
        let escrow = borrow_global_mut<Escrow>(escrow_addr);
        let now = timestamp::now_seconds();
        let due = *vector::borrow(&escrow.due_dates, installment_id);
        
        let required_amount = escrow.installment_amount;
        if (now > due + escrow.grace_period) {
            let days_late = (now - due - escrow.grace_period) / 86400;
            let penalty = (required_amount * escrow.penalty_rate * days_late) / 10000;
            required_amount = required_amount + penalty;
        };
        
        assert!(amount >= required_amount, 1001);
        let payment = coin::withdraw<AptosCoin>(payer, amount);
        coin::merge(&mut escrow.held_funds, payment);
        
        if (now <= due + escrow.grace_period && !table::contains(&escrow.paid_installments, installment_id)) {
            let to_release = coin::extract(&mut escrow.held_funds, escrow.installment_amount);
            coin::deposit(escrow.payee, to_release);
        };
        table::add(&mut escrow.paid_installments, installment_id, true);
    }

    public entry fun claim_funds(
        payee: &signer,
        escrow_addr: address
    ) acquires Escrow {
        let escrow = borrow_global_mut<Escrow>(escrow_addr);
        assert!(signer::address_of(payee) == escrow.payee, 1002);
        let amount = coin::value(&escrow.held_funds);
        if (amount > 0) {
            let to_release = coin::extract_all(&mut escrow.held_funds);
            coin::deposit(escrow.payee, to_release);
        };
    }
}