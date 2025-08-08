module MyModule::SimpleRental {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct to store rental details
    struct Rental has key, store {
        rent_amount: u64,   // Rent amount in tokens
        renter: address,    // Current renter's address
        is_rented: bool,    // Rental status
    }

    /// Function for the owner to create a rental listing
    public fun create_rental(owner: &signer, rent_amount: u64) {
        let rental = Rental {
            rent_amount,
            renter: @0x0,
            is_rented: false,
        };
        move_to(owner, rental);
    }

    /// Function for a renter to pay rent and occupy the property
    public fun rent_property(renter_signer: &signer, owner_addr: address) acquires Rental {
        let rental = borrow_global_mut<Rental>(owner_addr);

        assert!(!rental.is_rented, 1); // Already rented

        let payment = coin::withdraw<AptosCoin>(renter_signer, rental.rent_amount);
        coin::deposit<AptosCoin>(owner_addr, payment);

        rental.renter = signer::address_of(renter_signer);
        rental.is_rented = true;
    }
}
