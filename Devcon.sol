
pragma solidity ^0.4.19;

library SafeMath {

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Devcon is Ownable{

    using SafeMath for uint;
    bytes32 public eventName;
    uint public eventDate;
    uint public totalTickets;
    uint public TICKET_PRICE;
    uint public ticketRefundValidity;

    struct ticket{
        bytes32 name;
        bytes32 email;
        uint registrationDate;
    }
    
    mapping(address => ticket) public ticketHolders;
    event ticketPurchased(address _address, bytes32 _name, bytes32 _email, uint _registrationDate);

    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    function Devcon() public {
        
        owner = msg.sender;
        eventName = 'Devcon 2018';
        eventDate = now + 30 days;
        totalTickets = 100;
        TICKET_PRICE = 1 ether;
        ticketRefundValidity = 1 days;
    }
    
    function () public payable {
        PurchaseTicket('-', '-');
    }

    function PurchaseTicket(bytes32 _name, bytes32 _email) public payable onlyBefore(eventDate) {
        
        require(msg.value == TICKET_PRICE && ticketHolders[msg.sender].registrationDate == 0);
        
        totalTickets = totalTickets.sub(1);
        ticketHolders[msg.sender] = ticket(_name, _email, now);

        ticketPurchased(msg.sender, _name, _email, ticketHolders[msg.sender].registrationDate);
    }
    
    function GetTicketDetail(address _address) view public returns(bytes32,bytes32, uint) {

        return (ticketHolders[_address].name, ticketHolders[_address].email, ticketHolders[msg.sender].registrationDate);
    }
    
    function RefundTicket() public onlyBefore(eventDate) returns (bool) {
        
        require(ticketHolders[msg.sender].registrationDate != 0 && now < ticketHolders[msg.sender].registrationDate + ticketRefundValidity );
        
        msg.sender.transfer(TICKET_PRICE);
        ticketHolders[msg.sender] = ticket('x', 'x', 10);

        totalTickets = totalTickets.add(1);
        return true;
    }

    function getBalance() view public returns (uint) {
        return address(this).balance;
    }
    function CleanDevcon() public onlyOwner onlyAfter(eventDate) {
        
        //owner.transfer(1 ether);
        selfdestruct(owner);
    }

}