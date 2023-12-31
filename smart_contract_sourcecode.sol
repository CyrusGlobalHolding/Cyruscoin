// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// Interface for BEP20 token
interface IBEP20 {
  // Returns the total supply of the token
  function totalSupply() external view returns (uint256);

  // Returns the number of decimals used by the token
  function decimals() external view returns (uint8);

  // Returns the symbol of the token
  function symbol() external view returns (string memory);

  // Returns the name of the token
  function name() external view returns (string memory);

  // Returns the owner of the token contract
  function getOwner() external view returns (address);

  // Returns the balance of the specified account
  function balanceOf(address account) external view returns (uint256);

  // Transfers a specified amount of tokens to a given recipient
  function transfer(address recipient, uint256 amount) external returns (bool);

  // Returns the remaining allowance of a spender for a specific owner
  function allowance(address _owner, address spender) external view returns (uint256);

  // Approves a spender to spend a specific amount of tokens on behalf of the owner
  function approve(address spender, uint256 amount) external returns (bool);

  // Transfers a specified amount of tokens from a sender to a recipient
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  // Event emitted when tokens are transferred from one address to another
  event Transfer(address indexed from, address indexed to, uint256 value);

  // Event emitted when the allowance of a spender is updated by the owner
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () { }
  // Returns the address of the message sender
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }
  // Returns the data of the message
  function _msgData() internal pure returns (bytes memory) {
    return msg.data;
  }
}

library SafeMath {
  // Safe addition
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  // Safe subtraction
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  // Safe subtraction with error message
  function sub(uint256 a, uint256 b, string memory) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }
  
  // Safe multiplication
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  // Safe division
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  // Safe division with error message
  function div(uint256 a, uint256 b, string memory) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }

  // Safe modulo
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  // Safe modulo with error message
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // Constructor that sets the initial owner to the deployer of the contract
  constructor () {
    _owner = _msgSender();
    emit OwnershipTransferred(address(0), _owner);
  }

  // Function to get the current owner
  function owner() public view returns (address) {
    return _owner;
  }

  // Modifier to restrict access to only the owner
  modifier onlyOwner() {
    require(_msgSender() == _owner, "Ownable: caller is not the owner");
    _;
  }

  // Function to renounce ownership of the contract
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  // Function to transfer ownership of the contract to a new address
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  // Internal function to transfer ownership of the contract to a new address
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor() {
    _name = "CyrusCoin";
    _symbol = "CYRUS";
    _decimals = 18;
    _totalSupply = 1000000000000000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  // Returns the owner of the token contract
  function getOwner() external view override returns (address) {
    return owner();
  }

  // Returns the number of decimals used by the token
  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  // Returns the symbol of the token
  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  // Returns the name of the token
  function name() external view override returns (string memory) {
    return _name;
  }

  // Returns the total supply of the token
  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  // Returns the balance of the specified account
  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  // Transfers a specified amount of tokens to a given recipient
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  // Returns the remaining allowance of a spender for a specific owner
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  // Approves a spender to spend a specific amount of tokens on behalf of the owner
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  // Transfers a specified amount of tokens from a sender to a recipient
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  // Increases the allowance of a spender
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  // Decreases the allowance of a spender
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  // Mints new tokens and adds them to the specified account
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  // Internal function to transfer tokens from a sender to a recipient
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  // Internal function to mint new tokens and add them to the specified account
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  // Internal function to burn tokens from a specified account
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    // Check if the owner address is not the zero address
    require(owner != address(0), "BEP20: approve from the zero address");
    // Check if the spender address is not the zero address
    require(spender != address(0), "BEP20: approve to the zero address");

    // Update the allowance for the spender to spend the specified amount of tokens on behalf of the owner
    _allowances[owner][spender] = amount;
    // Emit an Approval event to notify listeners about the updated allowance
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    // Burn the specified amount of tokens from the account
    _burn(account, amount);
    // Update the allowance of the caller to spend the remaining tokens after the burn
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}
