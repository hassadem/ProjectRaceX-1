// This contract will keep track of car properties and transfer of ownership

pragma solidity ^0.8.0;

contract CarFactory {
    
    struct Car {
        uint32 id; // this is for indexing purpose
        string build; // Common, Uncommon, Rare, Legendary, Exotic, Ultra
        uint8 model; // 50, 30, 20, 15, 10, 5
        string buildRank; //U, H, E, S, P, L
        string buildColour; // ?
        string currentRank; // U, H, E, S, P, L
        uint16 xp; // to track xp - 0 - 1000+
        string currentColour; // ?
        uint16 rating; // to track the car rating - from 100 to 24000
        uint16 winCount; // to track the number of winning
        uint16 lossCount;
        uint16 experiencePoint; // to track the number of races participated
    }

    uint8[14] private upgradeType = [1,2,3,4,5,6,7,8,9,10]; // upgrade types correspond to the Upgrade Table

    // Array to keep track of cars and their attributes
    Car[] public cars;
    mapping(uint32 => address) public carIdToOwner; // to keep track of owner for each car Id
    mapping(address => uint) public ownerCarCount; // to keep track of how many cars per owner ? Do we need to restrict how many cars can one address owns?

    // to initiate the import of ERC20 and ERC1155 tokens
    constructor(address erc20addr, address erc1155addr) {
    // to import RWX token
    ERC20 erc20 = ERC20();

    // to import NFT owner
    ERC1155 erc1155 = ERC1155();
    }


    // modifier to restrict car races based on car rank which is determined by XP
    modifier onlyRankAbove() {
    }

    // modifier to restrict number of race to unlock the Upgrade type
    modifier onlyRaceAbove() {
    }

    // to allow upgrade of the car's current rank 
    // players can purchase upgrade by paying RWX token
    function upgradeRank() external {
    }

    // function to allow transfer ownership of car
    // the function will receive RWX token and then execute the transfer of NFT ownership together with car properties
    // need to call the NFT1155 contract to perform the transfer of ownership
    function transferCarOwnership() external {
    }

}