pragma solidity >=0.5.0;
import "./TaskCombination.sol";

contract TaskHelper is TaskCombination {

    //making our own modifiers
    modifier abovePriority(uint _priority, uint _taskId) {
        require(tasks[_taskId].priority >= _priority);
        _; //to call to rest of the function
    }

    //only tasks which are of Priority >= 5 can pick its own color
    function changeColor(
        uint _taskId, 
        uint _newRed, 
        uint _newGreen,
        uint _newBlue) external abovePriority(5, _taskId) {
        require(msg.sender == taskToOwner[_taskId]);
        tasks[_taskId].red = _newRed;
        tasks[_taskId].green = _newGreen;
        tasks[_taskId].blue = _newBlue;
    }

    //view functions don't cost any gas when they are called externally
    //because it doesn't change anything on the blockchain
    //just need to query local Ethereum node to run the function
    //BUT if a view function is called internally from another function in the same contract that's not a view function, it will still cost gas.
    function getTasksByOwner(address _owner) external view returns(uint[] memory) {
        //Instead of maintaining a list of tasks per owner, we use a central list
        //Arrays in memory will save gas
        //it must be created with a length argument
        uint[] memory result = new uint[](ownerTaskCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < tasks.length; i++) {
            if (taskToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        //it returns a memory array of indexes of Tasks
        return result;
    }

}
