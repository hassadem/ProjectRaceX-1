// This contract will allow users to pay for gas and transfer of ownership of gas 
// Need to import ERC20 (RWX) and ERC1155 contracts 
// Need to keep track of owner of GasStation to pay passive income in the form of RWX token
// will use Enumerable library to loop through the gas station owner
pragma solidity ^0.8.0;
contract GasStation {

    constructor() {

    }

    mapping(uint8 => address) public gasIdToOwner;

    // this function will receive payment for transfer of ownership of gas station
    function transferGasStationOwnership() external {
    }

}