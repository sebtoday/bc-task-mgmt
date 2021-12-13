pragma solidity >=0.5.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TaskFactory is Ownable {

    //State variables, permanently stored on blockchain
    uint colorDigits = 3;
    uint colorModulus = 10 ** colorDigits;
    //uint nextTaskID = 0;
    uint maxTaskCount = 20;
    //uint dailyTaskAddCount = 3;
    uint coolDownTime = 15 seconds;

    //Task
    struct Task{
        //uint taskID;
        //no need for taskID because we are using the array Index
        string description;
        string duedate;
        bool reminder;
        string createdate;
        uint red; //inside struct using uint32 can save more space/gas fee
        uint green; //using a smaller subtypes inside is called struct packing
        uint blue;
        uint32 priority; // 1 being the least important
        uint32 readyTime;
    }

    //event to let the front end knows a new task has been added to the blockchain
    event NewTask(uint taskID, string description, string duedate);

    //array of Tasks
    Task[] public tasks; //dynamic 

    //mapping between taskid and owner address
    mapping (uint => address) public taskToOwner;
    //mapping between owner address and number of tasks
    mapping (address => uint) ownerTaskCount;

    //Private means only other functions within the same contract will be able to call this function and add tasks.
    //Internal same as private but also accessible to contracts that inherit from this contract
    function _createTask(string memory _description, string memory _duedate, bool _reminder, uint _red, uint _green, uint _blue, uint32 _priority) internal {
        //later we can compare the owner's readytime with now to see if he can edit the task
        Task memory t = Task(_description, _duedate, _reminder, Strings.toString(block.timestamp), _red, _green, _blue, _priority, uint32(block.timestamp + coolDownTime));
        tasks.push(t); //adding new task to the Array
        uint id = tasks.length-1;

        //setting the array index to Sender
        taskToOwner[id] = msg.sender;
        ownerTaskCount[msg.sender]++;

        emit NewTask(id, _description, _duedate);
    }

    //view function doesn't modify data
    function _generateRandomRGB(string memory _str) public view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % colorModulus;
    }

    //public function to createRandomTask
    //external means this function can ONLY be called outside this contract
    function createRandomTask(string memory _description, string memory _duedate, bool _reminder, uint32 _priority) public {
        //owner cannot have more than 5 tasks
        require(ownerTaskCount[msg.sender] <= maxTaskCount);
        uint red = _generateRandomRGB(_description);
        uint green = _generateRandomRGB(_duedate);
        uint blue = _generateRandomRGB(Strings.toString(block.timestamp));
        _createTask(_description, _duedate, _reminder, red, green, blue, _priority);
    }

}
