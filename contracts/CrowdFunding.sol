// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    // odject campaign
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target; // target amount
        uint256 deadline;       
        uint256 amountCollected;
        string image;
        address[] donators; // an array of adresses of the donators
        uint256[] donations; // actual number of amounts donated
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public numberOfCampaigns = 0;

    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns(uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // is everything okay?
        require(campaign.deadline < block.timestamp, "The daedline should be a date in the future.");
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
        numberOfCampaigns++;

        return numberOfCampaigns-1 ; // index of the most recent campaign
    }

    // payable means we are going to send some cryptocurrency throughout the function
    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value; // sending from frontned 
        Campaign storage campaign = campaigns[_id];
        campaign.donators.push(msg.sender)
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent){
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory ) {
        return(campaigns[_id].donators , campaigns[_id].donations);
    }

    function getCampaigns() public view returns(Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i=0 ; i<numberOfCampaigns; i++){
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

}