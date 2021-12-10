pragma solidity >=0.5.0 <0.6.0;

contract TaskFactory {

    //State variables, permanently stored on blockchain
    uint colorDigits = 3;
    uint colorModulus = 10 ** colorDigits;

    //Task
    struct Task{
        uint taskID;
        string description;
        string duedate;
        boolean reminder;
        string createdate;
        uint red;
        uint green;
        uint blue;
    }

    //array of Tasks
    Task[] public tasks; //dynamic 

    function _createTask(string memory _description, string memory _duedate, boolean _reminder) private {
        uint red = _generateRandomRGB(_description);
        uint green = _generateRandomRGB(_duedate);
        uint blue = _generateRandomRGB(block.timestamp);
        Task t = Task(1,_description, _duedate, _reminder, '11/11/2020', red, green, blue);
        tasks.push(t); //adding new task to the Array
    }

    //view function doesn't modify data
    function _generateRandomRGB(string memory _str) public view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % colorModulus;
    }

}