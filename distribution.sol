pragma solidity ^0.8.0;
//SPDX-License-Identifier: Unlicensed

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract RacewayXredistribution is Ownable {
 
    address[] private holder;
    address[] private admin;
    address[] private charity;
    address private tokenAddress;
    ERC20 private RWX;
    uint256 private nftHolderShare = 60;
    uint256 private nftCharityShare = 20;
    event Deposit(address indexed payer, uint256 amount);

    constructor (address[] memory _holder, address[] memory _admin, address[] memory _charity, address _token) {
        holder = _holder;
        admin = _admin;
        charity = _charity;
        tokenAddress = _token;
        RWX = ERC20(tokenAddress);

    }
    //adding of address
    function setHolder (address _holder) external onlyOwner{
        require (holder.length <=20, "MAX_HOLDERS_REACHED");
        holder.push(_holder);
    }

    function setAdmin (address _admin) external onlyOwner{
        admin.push(_admin);
    }

    function setCharity (address _charity) external onlyOwner{
        charity.push(_charity);
    }
    // remove NFTHolder function 
    function removeHolder (address _holder) external onlyOwner {
        uint deleteIndex; 
        // find out the index of the target address
        for (uint256 i=0; i <= holder.length-1; i++) {
            if (holder[i]== _holder) {
                deleteIndex = i;
            }
        }
        // replace the target address with the subsequent address
        for (uint256 j=deleteIndex; j<= holder.length-1; j++) {
            holder[j] = holder[j+1];
        }
        //delete the last address
        holder.pop();
    }

    function removeAdmin (address _admin) external onlyOwner {
        uint deleteIndex; 
        // find out the index of the target address
        for (uint256 i=0; i <= admin.length-1; i++) {
            if (admin[i]== _admin) {
                deleteIndex = i;
            }
        }
        // replace the target address with the subsequent address
        for (uint256 j=deleteIndex; j<= admin.length-1; j++) {
            admin[j] = admin[j+1];
        }
        //delete the last address
        admin.pop();
    }

    function removeCharity (address _charity) external onlyOwner {
        uint256 deleteIndex; 
        // find out the index of the target address
        for (uint256 i=0; i <= charity.length-1; i++) {
            if (charity[i]== _charity) {
                deleteIndex = i;
            }
        }
        // replace the target address with the subsequent address
        for (uint256 j=deleteIndex; j<= charity.length-1; j++) {
            charity[j] = charity[j+1];
        }
        //delete the last address
        admin.pop();
    }

    // set the NFT holder and charity share of RWX token deposited
    function setNFTShare(uint256 _holderShare, uint256 _charityShare) external onlyOwner {
        require((_holderShare + _charityShare) <= 100, "INVALID");
        nftHolderShare = _holderShare;
        nftCharityShare = _charityShare;
    }

    function setTokenAddress(address _token) external onlyOwner {
        require(_token != address(0), "INVALID_ADDRESS");
        tokenAddress = _token; 
        RWX = ERC20(tokenAddress);
    }


    //sharing percentage for holders, admin and charity addresses
    // function setShare (address _holder, address _admin, address _charity, uint256 _share) private {
    //     if(address == _holder) {
    //         share == "610**2";
    //     }else if(address == _admin) {
    //         share == "2101";
    //     }else (address == _charity) {
    //         share == "2*101";
    //     }

    //     }
    
    // deposit RWX token
    function deposit (uint256 amount) external returns (bool) {
        require(RWX.balanceOf(msg.sender) >= amount, "INSUFFICIENT_BALANCE");
        require(RWX.allowance(msg.sender, address(this))>= amount, "INSUFFICIENT_ALLOWANCE");
        // transfer the amount to this contract
        bool success = RWX.transferFrom(msg.sender, address(this), amount);
        require(success, 'TRANSFER_FAILED');
        
        // transfer to holders of NFTs
        uint256 n = holder.length;
        uint256 m = charity.length;
        for (uint256 i = 0; i <= n-1; i++) {
            // 60% to 20 NFT holders
            RWX.transfer(holder[i], (amount * nftHolderShare)/(100 * n));
        }
        // transfer to charity
        for (uint256 j=0; j<= m-1; j++) {
            // 20% to charity holders
            RWX.transfer(charity[j], (amount * nftCharityShare)/(100 * m));
        }
        //20% remaining transfer to owner
        if (100 - nftHolderShare - nftCharityShare >=0 && RWX.balanceOf(address(this))>=0) {
            RWX.transfer(Ownable.owner(), amount * (100 - nftHolderShare - nftCharityShare)/100);
        }
        emit Deposit(msg.sender, amount);
        return true;
    }

    function transfer(address _to, uint _amount) external returns (bool) {
        require(RWX.balanceOf(msg.sender) >= _amount, "INSUFFICIENT_BALANCE");
        
        RWX.transfer(_to, _amount);
        return true;
    }

} 