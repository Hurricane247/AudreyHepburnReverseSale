pragma solidity ^0.4.18;

 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
interface reverseCrowdsaleInterface {
    function updateReverseCrowdsaleInfo (address ad, uint tok, uint weis) external;
    function getReverseCrowdSaleStatus() constant external returns(bool);
}
contract AudreyHepburnToken is ERC20Interface,Ownable {

   using SafeMath for uint256;
   
   string public name;
   string public symbol;
   uint256 public decimals;

   uint256 public _totalSupply;
   mapping(address => uint256) tokenBalances;
   address ownerWallet;
   // Owner of account approves the transfer of an amount to another account
   mapping (address => mapping (address => uint256)) allowed;
   uint256 exchangeRate;
   bool isCrowdsaleEnabled;
   reverseCrowdsaleInterface reverseCrowdsale;
   address reverseCrowdsaleAddress;
   /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
    function AudreyHepburnToken(address wallet) public {
        owner = msg.sender;
        ownerWallet = wallet;
        name  = "Audrey_ArtDeal";
        symbol = "AAD";
        decimals = 18;
        _totalSupply = 1200 * 10 ** uint(decimals);
        tokenBalances[wallet] = _totalSupply;   //Since we divided the token into 10^18 parts
        exchangeRate = 1172 * 10 ** 11;
    }
    
     // Get the token balance for account `tokenOwner`
     function balanceOf(address tokenOwner) public constant returns (uint balance) {
         return tokenBalances[tokenOwner];
     }
  
     // Transfer the balance from owner's account to another account
     function transfer(address to, uint tokens) public returns (bool success) {
         require(to != address(0));
         require(tokens <= tokenBalances[msg.sender]);
         if (to == reverseCrowdsaleAddress)
         {
            require (reverseCrowdsale.getReverseCrowdSaleStatus() == true);
            uint amountToSend = tokens.div(10**uint(decimals));
            amountToSend = amountToSend.mul(exchangeRate);
            msg.sender.transfer(amountToSend);
            tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(tokens);
            tokenBalances[ownerWallet] = tokenBalances[ownerWallet].add(tokens);
            Transfer(msg.sender, ownerWallet, tokens);
            reverseCrowdsale.updateReverseCrowdsaleInfo(msg.sender,tokens,amountToSend);
         }
         else
         {
         tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(tokens);
         tokenBalances[to] = tokenBalances[to].add(tokens);
         Transfer(msg.sender, to, tokens);
         }
         return true;
         
     }
  
     /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= tokenBalances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    tokenBalances[_from] = tokenBalances[_from].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
     /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

     // ------------------------------------------------------------------------
     // Total supply
     // ------------------------------------------------------------------------
     function totalSupply() public constant returns (uint) {
         return _totalSupply  - tokenBalances[address(0)];
     }
     
    
     
     // ------------------------------------------------------------------------
     // Returns the amount of tokens approved by the owner that can be
     // transferred to the spender's account
     // ------------------------------------------------------------------------
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
         return allowed[tokenOwner][spender];
     }
     
     /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

     
     // ------------------------------------------------------------------------
     // Don't accept ETH
     // ------------------------------------------------------------------------
     function () public payable {

     }
 
     // ------------------------------------------------------------------------
     // Owner can transfer out any accidentally sent ERC20 tokens
     // ------------------------------------------------------------------------
     function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
         return ERC20Interface(tokenAddress).transfer(owner, tokens);
     }
     
     //only to be used by the ICO
     
     function mint(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[wallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer's balance
      tokenBalances[wallet] = tokenBalances[wallet].sub(tokenAmount);                        // subtracts amount from seller's balance
      Transfer(wallet, buyer, tokenAmount); 
      _totalSupply = _totalSupply.sub(tokenAmount);
    }
    function setReverseContractAddress(address addr) public{
        require(msg.sender == ownerWallet);
        reverseCrowdsale = reverseCrowdsaleInterface(addr);
        reverseCrowdsaleAddress = addr;
    }
    function claimFunds() public onlyOwner {
        ownerWallet.transfer(this.balance);
    }
    function showMyEtherBalance() public constant onlyOwner returns (uint) {
        return this.balance;
    }
   
    function refundToBuyers(address[] buyersList, uint rate) public onlyOwner {
        for (uint i=0;i<buyersList.length;i++)
        {
            uint amountToSend = balanceOf(buyersList[i]).mul(rate);
            buyersList[i].transfer(amountToSend);
        }
    }
}

contract AudreyHepburnCrowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  AudreyHepburnToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // rate of tokens
  uint256 public rate = 5858 * 10 ** 10;

  // amount of raised money in wei
  uint256 public weiRaised;

  uint256 TOKENS_SOLD;
  uint256 maxTokensToSale = 1200 * 10 ** 18;
  
  //uint256 softCap = 702960 * 10 ** 11;
  
  address[] buyersList;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function AudreyHepburnCrowdsale(uint256 _startTime, address _wallet) public 
  {
    startTime = now;
    endTime = startTime + 5 days;

    require(startTime >=now);
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
  }
  
   // creates the token to be sold.
  function createTokenContract(address wall) internal returns (AudreyHepburnToken) {
    return new AudreyHepburnToken(wall);
  }
  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }
   
  // low level token purchase function
  // Minimum purchase can be of 1 ETH
  
  function buyTokens(address beneficiary) public payable {
    
    require(beneficiary != 0x0);
    require(validPurchase());
    
    require(TOKENS_SOLD<maxTokensToSale);
    uint256 weiAmount = msg.value;
    
    // calculate token amount to be created
    
    uint256 tokens = weiAmount.div(rate);
    tokens = tokens.mul(10**18);
    require(TOKENS_SOLD+tokens<=maxTokensToSale);
    
    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(wallet, beneficiary, tokens); 
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    buyersList.push(beneficiary);
    token.transfer(msg.value);
    }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function claimFunds() public {
    require(msg.sender == wallet);
    token.claimFunds();
  }
  
  function refundToBuyers() public {
      require (msg.sender == wallet && hasEnded() && TOKENS_SOLD <maxTokensToSale);
      token.refundToBuyers(buyersList, rate);
    }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

   // @return true if crowdsale event has ended
   function hasEnded() public constant returns (bool) {
     return now > endTime;
    }
    
    // ------------------------------------------------------------------------
    // Remaining tokens for sale
    // ------------------------------------------------------------------------
    function remainingTokensForSale() public constant returns (uint) {
         return maxTokensToSale - TOKENS_SOLD;
    }
 
    function showAvailableEtherBalance() public constant returns (uint) {
         return token.showMyEtherBalance();
    }
}
