pragma solidity ^0.4.18;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract AudreyHepburnReverseCrowdsale is Ownable {
      uint public totalTokensReceived=0;
      uint public totalWeiReturned=0;
      bool public isReverseCrowdsaleEnabled=false;
      mapping(address=>uint)  addressForWeiReturned;
      mapping(address=>uint)  addressForTokensReceived;
      
      function AudreyHepburnReverseCrowdsale(address wallet) public {
          owner = wallet;
      }
         
      function enableReverseCrowdsale() public onlyOwner {
          isReverseCrowdsaleEnabled=true;
      }
      
      function disableReverseCrowdsale() public onlyOwner {
          isReverseCrowdsaleEnabled=false;
      }
      
      function updateReverseCrowdsaleInfo (address ad, uint tok, uint weis) public  {
          totalTokensReceived+=tok;
          totalWeiReturned+=weis;
          addressForTokensReceived[ad]+=tok;
          addressForWeiReturned[ad]+=weis;

      }
       function getWeiReturnedByAddress (address ad) view public returns(uint) {
           return addressForWeiReturned[ad];
       }
        function getTokensReceivedByAddress (address ad) view public returns(uint) {
           return addressForTokensReceived[ad];
       }
       
        function getReverseCrowdSaleStatus () constant public returns(bool) {
           return isReverseCrowdsaleEnabled;
       }
}
