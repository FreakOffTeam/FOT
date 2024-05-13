// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title IFOTVesting Interface
 * @dev Interface for FOT vesting contract
 */
interface IFOTVesting {
    /**
     * @dev User vesting schedule details
     */
    struct UserVesting {
        uint256 totalAmount; // Total amount vested for the beneficiary.
        uint256 claimedAmount; // Amount already claimed by the beneficiary.
        uint64 startDate; // Timestamp when vesting starts.
        address beneficiary; // Address of the beneficiary receiving the vested tokens.
    }

    /**
     * @dev Vesting plan details
     */
    struct VestingPlan {
        uint64 startDate; // Start timestamp
        uint64 cliff; // Cliff period
        uint64 duration; // Total duration
        bool revocable; // Revocable or not
        uint16 initialReleasePercentage; // Initial release percentage
        bytes32 poolName; // Liquidity pool name
    }

    /**
     * @dev Holder vesting stats
     */
    struct HolderStat {
        uint256 vestingCount; // Number of vestings
        uint256 vestingAmount; // Total vesting amount
        uint256 claimedAmount; // Total claimed
    }

    /**
     * @dev Emitted when vesting is claimed
     * @param amount Claimed amount
     * @param beneficiary Beneficiary address
     * @param planId Plan ID

     */
    event Claimed(uint256 planId, uint256 amount, address indexed beneficiary);

    /**
     * @dev Emitted when vesting is revoked
     * @param amount Revoked amount
     * @param beneficiary Beneficiary address
     * @param planId Plan ID

     */
    event Revoked(uint256 planId, uint256 amount, address indexed beneficiary);

    /**
     * @dev Emitted when vesting plan created
     * @param planId Plan ID
     * @param _startDate Start timestamp
     * @param _cliff Cliff duration
     * @param _duration Total duration
     * @param _revocable If revocable
     * @param _initialReleasePercentage Initial release percentage
     * @param poolName Liquidity pool name
     */
    event VestingPlanCreated(
        uint256 planId,
        uint64 _startDate,
        uint64 _cliff,
        uint64 _duration,
        bool _revocable,
        uint16 _initialReleasePercentage,
        bytes32 poolName
    );

    /**
     * @dev Emitted when debt is created
     * @param amount debt amount
     * @param dest Beneficiary
     */
    event DebtCreated(uint256 amount, address indexed dest);

    /**
     * @dev Emitted when debt is created
     * @param planId Plan ID
     * @param amount debt amount
     * @param dest Beneficiary
     */
    event DebtCreatedInPlan(
        uint256 planId,
        uint256 amount,
        address indexed dest
    );

    /**
     * @dev Emitted when vesting created
     * @param planId Plan ID
     * @param beneficiary Beneficiary
     * @param start Start timestamp
     * @param totalAmount Total vesting amount
     */
    event VestingCreated(
        uint256 planId,
        address indexed beneficiary,
        uint64 start,
        uint256 totalAmount
    );

    /**
     * Emitted when tge seted
     * @param planId Plan Id
     * @param tgeDate TGE Date
     */
    event VestingTGESeted(uint256 planId, uint256 tgeDate);
    
    // External functions

    /**
     * @dev Creates new vesting plan
     * @param _startDate Start timestamp
     * @param _cliff Cliff duration
     * @param _duration Total duration
     * @param _revocable If revocable
     * @param _initialReleasePercentage Initial release percentage
     * @param poolName Liquidity pool name
     */
    function createVestingPlan(
        uint64 _startDate,
        uint64 _cliff,
        uint64 _duration,
        bool _revocable,
        uint16 _initialReleasePercentage,
        bytes32 poolName
    ) external;

    /**
     * @dev Add tge time to vesting plan
     * @param _planID plan id
     * @param tgeTime tge time
     */
    function setVestingPlanTGE(uint256 _planID, uint256 tgeTime) external;

    /**
     * @dev Creates new vesting schedule
     * @param _beneficiary Beneficiary address
     * @param _startDate Start timestamp
     * @param _amount Total vesting amount
     * @param _planID Plan ID
     * @return Success status
     */
    function createVesting(
        address _beneficiary,
        uint64 _startDate,
        uint256 _amount,
        uint256 _planID
    ) external returns (bool);

    /**
     * @dev Revokes vesting schedule
     * @param _beneficiary Beneficiary address
     * @param _planID Plan ID
     */
    function revoke(address _beneficiary, uint256 _planID) external;

    /**
     * @dev Claims vested tokens
     * @param _planID Plan ID
     */
    function claim(uint256 _planID) external;

    /**
     * @dev Creates vesting debt
     * @param _beneficiary Beneficiary address
     * @param _debtAmount Debt amount
     */
    function setDebt(address _beneficiary, uint256 _debtAmount) external;

    /**
     * @dev Gets total vesting amount
     * @return Total vesting amount
     */
    function totalVestingAmount() external view returns (uint256);

    /**
     * @dev Gets vesting plan details
     * @param planId Plan ID
     * return Vesting plan details
     */
    function vestingPlans(
        uint256 planId
    )
        external
        view
        returns (
            uint64 startDate,
            uint64 cliff,
            uint64 duration,
            bool revocable,
            uint16 initialReleasePercentage,
            bytes32 poolName
        );
    /**
     * @dev Gets vesting TGES
     * @param planId Plan ID
     * @return tge Vesting plan tge timestamp
     */
    function vestingTGEs(uint256 planId) external view returns (uint256 tge);
    /*
     * @dev Gets user vesting details
     * @param _beneficiary Beneficiary address
     * @param planID Plan ID
     * @param index Vesting index
     * @return User vesting details
     */
    function userVestings(
        address _beneficiary,
        uint256 planID,
        uint256 index
    )
        external
        view
        returns (
            uint256 totalAmount,
            uint256 claimedAmount,
            uint64 startDate,
            address beneficiary
        );

    /*
     * @dev Gets holder vesting stats
     * @param _beneficiary Holder address
     * @return Holder vesting stats
     */
    function holdersStat(
        address _beneficiary
    )
        external
        view
        returns (
            uint256 vestingCount,
            uint256 vestingAmount,
            uint256 claimedAmount
        );
}
