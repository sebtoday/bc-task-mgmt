pragma solidity >=0.5.0;
import "./TaskFactory.sol";


//Interfacing with CryptoKitties
abstract contract KittyInterface {
  function getKitty(uint256 _id) external virtual view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract TaskCombination is TaskFactory{

    //address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // Initialize kittyContract here using `ckAddress` from above
    KittyInterface kittyContract;
    //if function set to external then anyone can change this to any addr
    function setKittyContractAddress(address _address) external onlyOwner{
      kittyContract = KittyInterface(_address);
    }

    //storage pointer to a struct is being passed to private or internal function
    //so we don't need to use TaskID to look it up
    function _triggerCooldown(Task storage _task) internal {
      _task.readyTime = uint32(block.timestamp + coolDownTime);
    }

    function _isReady(Task storage _task) internal view returns (bool) {
        return (_task.readyTime <= block.timestamp);
    }

    //make this internal so it's more secure
    function combineTasks(uint _taskId1, uint _taskId2) internal {
        //requiring both tasks belong to the same owner
        require(msg.sender == taskToOwner[_taskId1]);
        require(msg.sender == taskToOwner[_taskId2]);

        Task storage myTask1 = tasks[_taskId1];
        Task storage myTask2 = tasks[_taskId2];

        //make sure both tasks are ready
        require(_isReady(myTask1));
        require(_isReady(myTask2));

        uint red;
        uint green;
        uint blue;
        //Using CryptoKitty to get random RGB
        (,,,,,,,red,green,blue) = kittyContract.getKitty(_taskId1*_taskId2); 

        //no need to trigger cooldown because it's inside _createTask function
        _createTask(
            string(abi.encodePacked(myTask1.description, " & ", myTask2.description)),
            myTask2.duedate, //needs to add date compare function here later
            true,
            red, 
            green, 
            blue,
            myTask2.priority //needs to change to use the higher priority of the two
        );
    }
}