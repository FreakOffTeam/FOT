// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IFOTDistributor} from "../distributor/IFOTDistributor.sol";
import {IAccessRestriction} from "../accessRestrictions/IAccessRestriction.sol";
import {IFOTVesting} from "../vesting/IFOTVesting.sol";
import {IFOT} from "../token/IFOT.sol";

/**
 * @title FOTVesting
 * @dev Manages vesting plans and FOT distributions
 */
contract FOTVesting is ReentrancyGuard, IFOTVesting {
  // Total vesting amount across all schedules
  uint256 public override totalVestingAmount;

  // Vesting plan details by plan ID
  mapping(uint256 => VestingPlan) public override vestingPlans;
  mapping(uint256 => uint256) public override vestingTGEs;

  // User vesting schedules by user and plan ID
  mapping(address => mapping(uint256 => UserVesting[])) public override userVestings;

  // Vesting stats by user
  mapping(address => HolderStat) public override holdersStat;

  // Revocation status by user and plan ID
  mapping(address => mapping(uint256 => bool)) public hasRevoked;

  // FOT distributor reference
  IFOTDistributor public immutable FOTDistributor;

  // Access control reference
  IAccessRestriction public immutable accessRestriction;

  // Counter for vesting plan IDs
  uint256 private _planId;

  /**
   * @dev Reverts if address is invalid
   */
  modifier validAddress(address _addr) {
    require(_addr != address(0), "FOTVesting::Not valid address");
    _;
  }

  /**
   * @dev Reverts if caller is not admin
   */
  modifier onlyAdmin() {
    accessRestriction.ifAdmin(msg.sender);
    _;
  }

  /**
   * @dev Reverts if caller unauthorized
   */
  modifier onlyAdminOrApprovedContract() {
    accessRestriction.ifAdminOrApprovedContract(msg.sender);
    _;
  }

  /**
   * @dev Reverts if vesting revoked
   */
  modifier onlyNotRevoked(address _beneficiary, uint256 _planID) {
    require(!hasRevoked[_beneficiary][_planID], "FOTVesting::Your vesting are revoked");
    _;
  }

  /**
   * @dev Reverts if plan not revocable
   */
  modifier onlyRevocablePlan(uint256 _planID) {
    require(vestingPlans[_planID].revocable, "FOTVesting:Vesting is not revocable");
    _;
  }

  /**
   * @dev FOTVesting Constructor
   */
  constructor(address _FOTDistributor, address _accessRestrictionAddress) {
    FOTDistributor = IFOTDistributor(_FOTDistributor);
    accessRestriction = IAccessRestriction(_accessRestrictionAddress);
  }

  /**
   * @dev Creates a new vesting plan
   * @param _startDate Start timestamp
   * @param _cliff Cliff duration
   * @param _duration Total duration
   * @param _revocable If revocable
   * @param _initialReleasePercentage Initial release percentage
   * @param _poolName Liquidity pool name
   */
  function createVestingPlan(
    uint64 _startDate,
    uint64 _cliff,
    uint64 _duration,
    bool _revocable,
    uint16 _initialReleasePercentage,
    bytes32 _poolName
  ) external override onlyAdmin {
    // Validate cliff and duration
    require(_cliff <= _duration, "FOTVesting::Cliff priod is invalid");
    require(_duration > 0, "FOTVesting::Duration is not seted");

    require(_startDate >= uint64(block.timestamp), "FOTVesting::start date is not valid");

    // Create vesting plan
    VestingPlan memory plan = VestingPlan(
      _startDate,
      _cliff,
      _duration,
      _revocable,
      _initialReleasePercentage,
      _poolName
    );

    // Store plan by next plan ID
    vestingPlans[_planId] = plan;

    // Emit event
    emit VestingPlanCreated(_planId, _startDate, _cliff, _duration, _revocable, _initialReleasePercentage, _poolName);

    // Increment plan ID counter
    _planId += 1;
  }

  /**
   * @dev Add tge time to vesting plan
   * @param _planID plan id
   * @param _tgeDate tge time
   */
  function setVestingPlanTGE(uint256 _planID, uint256 _tgeDate) external onlyAdmin {
    
    VestingPlan memory vestingPlan = vestingPlans[_planID];
    require(_tgeDate >= vestingPlan.startDate, "FOTVesting::SetTGETime:TGE is not valid");
    vestingTGEs[_planID] = _tgeDate;
    emit VestingTGESeted(_planID, _tgeDate);
  }

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
  ) external override onlyAdminOrApprovedContract validAddress(_beneficiary) returns (bool) {
    // Validate plan and amount
    require(_planID <= _planId, "FOTVesting::Plan is not exist");
    require(_amount > 0, "FOTVesting::Amount is too low");

    // Get plan details
    VestingPlan memory vestingPlan = vestingPlans[_planID];

    // Validate start date
    require(_startDate >= vestingPlan.startDate, "FOTVesting::createVesting:StartDate is not valid");

    // Create user vesting schedule
    UserVesting memory userVesting = UserVesting(
      _amount, // Total vesting amount
      0, // Initial claimed amount
      _startDate, // Start date
      _beneficiary // the beneficiary address
    );

    // Add new vesting schedule
    userVestings[_beneficiary][_planID].push(userVesting);

    // Update total vesting amount
    totalVestingAmount += _amount;

    // Update beneficiary stats
    HolderStat storage holderStat = holdersStat[_beneficiary];
    holderStat.vestingAmount += _amount;
    holderStat.vestingCount += 1;

    // Emit event
    emit VestingCreated(_planID, _beneficiary, _startDate, _amount);

    return true;
  }

  /**
   * @dev Revokes vesting schedule
   * @param _beneficiary Beneficiary address
   * @param _planID Plan ID
   */
  function revoke(
    address _beneficiary,
    uint256 _planID
  )
    external
    override
    onlyAdmin
    onlyRevocablePlan(_planID)
    validAddress(_beneficiary)
    onlyNotRevoked(_beneficiary, _planID)
  {
    // Get currently claimable amount
    uint256 claimableAmount = _getClaimableToken(_beneficiary, _planID);

    // Release claimable amount
    _release(_planID, _beneficiary, claimableAmount);

    // Mark as revoked
    hasRevoked[_beneficiary][_planID] = true;

    // Emit event
    emit Revoked(_planID, claimableAmount, _beneficiary);
  }

  /**
   * @dev Claims vested tokens
   * @param _planID Plan ID
   */
  function claim(uint256 _planID) external override nonReentrant onlyNotRevoked(msg.sender, _planID) {
    // Get claimable amount
    uint256 claimableAmount = _getClaimableToken(msg.sender, _planID);

    // Release tokens
    _release(_planID, msg.sender, claimableAmount);

    // Emit event
    emit Claimed(_planID, claimableAmount, msg.sender);
  }

  /**
   * @dev Creates vesting debt
   * @param _beneficiary Beneficiary address
   * @param _debtAmount Debt amount
   */
  function setDebt(
    address _beneficiary,
    uint256 _debtAmount
  ) external override onlyAdminOrApprovedContract validAddress(_beneficiary) {
    // Get beneficiary stats
    HolderStat storage holderStat = holdersStat[_beneficiary];

    // Validate debt amount
    require(holderStat.vestingAmount >= (_debtAmount + holderStat.claimedAmount), "FOTVesting::Debt limit Exceeded");

    // Loop through vesting schedules
    uint256 remainingDebt = _debtAmount;
    uint256 availableAmount = 0;
    uint256 debtToClaim = 0;
    for (uint16 i = 0; i < _planId && remainingDebt > 0; i++) {
      if (!hasRevoked[_beneficiary][i]) {
        UserVesting[] storage vestingList = userVestings[_beneficiary][i];
        for (uint16 j = 0; j < vestingList.length && remainingDebt > 0; j++) {
          UserVesting storage currentVesting = vestingList[j];

          // Get available vesting amount
          availableAmount = currentVesting.totalAmount - currentVesting.claimedAmount;

          // Calculate debt to claim from this vesting
          debtToClaim = Math.min(remainingDebt, availableAmount);

          // Update claimed amount
          currentVesting.claimedAmount += debtToClaim;

          // Update remaining debt
          remainingDebt -= debtToClaim;

          emit DebtCreatedInPlan(i, debtToClaim, _beneficiary);
        }
      }
    }

    // Update total claimed
    holderStat.claimedAmount += _debtAmount;

    // Update total vesting amount
    totalVestingAmount -= _debtAmount;

    // Emit event
    emit DebtCreated(_debtAmount, _beneficiary);
  }

  /*
   * @dev Releases vested tokens to beneficiary
   * @param _beneficiary Beneficiary address
   * @param _planID Plan ID
   * @param __releaseAmount release amount
   */
  function _release(uint256 _planID, address _beneficiary, uint256 _releaseAmount) private {
    // Validate amount
    require(_releaseAmount > 0, "FOTVesting::Not enough vested tokens");

    // Get vesting plan
    VestingPlan memory vestingPlan = vestingPlans[_planID];

    // Update beneficiary stats
    HolderStat storage holderStat = holdersStat[_beneficiary];
    holderStat.claimedAmount += _releaseAmount;

    // Update total vesting amount
    totalVestingAmount -= _releaseAmount;

    // Distribute tokens
    bool success = FOTDistributor.distribute(vestingPlan.poolName, _releaseAmount, _beneficiary);

    // Require success
    require(success, "FOTVesting::Fail transfer");
  }

  /**
   * @dev Calculates currently claimable tokens
   * @param _beneficiary Beneficiary address
   * @param _planID Plan ID
   */
  function _getClaimableToken(address _beneficiary, uint256 _planID) private returns (uint256) {
    // Get vesting schedules
    UserVesting[] storage vestingList = userVestings[_beneficiary][_planID];

    // Validate vesting exists
    require(vestingList.length != 0, "FOTVesting::No vesting");

    // Get plan details
    VestingPlan memory vestingPlan = vestingPlans[_planID];
    uint256 tge = vestingTGEs[_planID];

    require(tge > 0 && tge > vestingPlan.startDate, "FOTVesting::TGE is not valid");

    uint256 endDate = tge + vestingPlan.duration;
    uint256 cliffDate = tge + vestingPlan.cliff;

    // Get current time
    uint64 currentTime = uint64(block.timestamp);

    // Initialize claimable amount
    uint256 claimableAmount = 0;
    uint256 availableAmount = 0;
    uint256 releaseAmount = 0;
    uint64 elapsedTime = 0;
    uint64 unlockDuration = 0;
    uint256 remainingAfterInitial = 0;
    // Loop through vesting schedules
    for (uint256 i = 0; i < vestingList.length; i++) {
      // Get reference to current vesting schedule
      UserVesting storage currentVesting = vestingList[i];

      // Ensure correct beneficiary
      require(currentVesting.beneficiary == _beneficiary, "FOTVesting::Only beneficiary can claim");
      if (currentVesting.claimedAmount == currentVesting.totalAmount) {
        continue; // Skip fully claimed schedules
      }

      // Check if fully vested
      if (currentTime >= endDate) {
        releaseAmount = currentVesting.totalAmount;
      } else if (currentTime > cliffDate) {
        // Calculate partial vesting amount
        elapsedTime = uint64(currentTime - cliffDate);
        unlockDuration = uint64(endDate - cliffDate);
        
        releaseAmount = (currentVesting.totalAmount * vestingPlan.initialReleasePercentage) / 10000;

        remainingAfterInitial = currentVesting.totalAmount - releaseAmount;
        
        releaseAmount += (remainingAfterInitial * elapsedTime) / unlockDuration;
      } else if (currentTime >= tge) {
        releaseAmount = (currentVesting.totalAmount * vestingPlan.initialReleasePercentage) / 10000;
      }

      // Calculate available amount
      availableAmount = releaseAmount > currentVesting.claimedAmount ? releaseAmount - currentVesting.claimedAmount : 0;

      // Add to claimable amount
      claimableAmount += availableAmount;

      // Update claimed
      currentVesting.claimedAmount += availableAmount;
    }
    return claimableAmount;
  }
}
