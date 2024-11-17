module PeerToPeerTutoring::Tutoring {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct to represent a tutoring session.
    struct TutoringSession has store, key {
        tutor: address,
        amount: u64,      // Payment for the session
        is_completed: bool,  // Whether the session is marked as complete
    }

    /// Function for a tutor to create a session with a set fee.
    public fun create_session(tutor: &signer, amount: u64) {
        let session = TutoringSession {
            tutor: signer::address_of(tutor),
            amount,
            is_completed: false,
        };
        move_to(tutor, session);
    }

    /// Function for a student to pay for and complete the session.
    public fun complete_session(student: &signer, tutor_address: address) acquires TutoringSession {
        let session = borrow_global_mut<TutoringSession>(tutor_address);

        // Ensure the session is not already completed
        assert!(!session.is_completed, 1);

        // Transfer the session fee from the student to the tutor
        let payment = coin::withdraw<AptosCoin>(student, session.amount);
        coin::deposit<AptosCoin>(tutor_address, payment);

        // Mark the session as completed
        session.is_completed = true;
    }
}
