pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;                                      
        uint noOfVoters;
        mapping(address=>bool) voters;                      //map for voters to check they voted or not
    }
    mapping(uint=>Request) public requests;                 //map to provide serial number to each request
    uint public numRequests;

    modifier onlyManager(){
        require(msg.sender==manager , " Only manager can access this function");
        _;
    }


    constructor(uint _target,uint _deadline) public{
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    } 


// function to send ether  

    function sendEther()public payable{
        require(block.timestamp<deadline," Deadline has passed");
        require(msg.value>=minimumContribution," Minimum Contribution is not met");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
//function to get balance

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

//function to refund in case of failure of project

    function refund()public{
        require(block.timestamp>deadline && raisedAmount<target , " You are not eligible for refund");
        require(contributors[msg.sender]>0 , "You are not contributor");
        address payable user=(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

//function to create the number of requests from manager

    function createRequests(string memory _description, address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;                                                               //providing serial number to each request
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }

//function to vote a particular request

    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0 , " You must be a contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false , "You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }    

// function for pay the amount to the organisation

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target , "Target not reached");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false , "The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2 , "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}