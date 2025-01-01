import "./NFTGovernanceToken.sol";

contract DAOGovernance {
    struct Proposal {
        string description;
        uint256 voteCount;
        uint256 voteWeight;
        uint256 deadline;
        bool executed;
    }

    NFTGovernanceToken public governanceNFT;
    mapping(address => uint256) public delegatedVotes;
    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed proposalId, string description, uint256 deadline);
    event Voted(uint256 indexed proposalId, address voter, uint256 weight);
    event Delegated(address from, address to, uint256 weight);

    constructor(address _nftAddress) {
        governanceNFT = NFTGovernanceToken(_nftAddress);
    }

    modifier onlyNFTOwner() {
        require(governanceNFT.balanceOf(msg.sender) > 0, "Not an NFT owner");
        _;
    }

    function createProposal(string memory _description, uint256 _duration) external onlyNFTOwner {
        uint256 deadline = block.timestamp + _duration;
        proposals[proposalCount] = Proposal(_description, 0, 0, deadline, false);
        emit ProposalCreated(proposalCount, _description, deadline);
        proposalCount++;
    }

    function vote(uint256 _proposalId, uint256 _votes) external onlyNFTOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting period ended");
        require(_votes > 0, "Invalid vote count");

        uint256 nftCount = governanceNFT.balanceOf(msg.sender);
        uint256 weight = _calculateQuadraticVote(nftCount);

        proposal.voteCount += _votes;
        proposal.voteWeight += weight;

        emit Voted(_proposalId, msg.sender, weight);
    }

    function delegate(address to, uint256 _proposalId) external onlyNFTOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting period ended");
        require(to != msg.sender, "Cannot delegate to self");

        uint256 nftCount = governanceNFT.balanceOf(msg.sender);
        delegatedVotes[to] += _calculateQuadraticVote(nftCount);

        emit Delegated(msg.sender, to, delegatedVotes[to]);
    }

    function _calculateQuadraticVote(uint256 nftCount) internal pure returns (uint256) {
        return sqrt(nftCount);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function executeProposal(uint256 _proposalId) external onlyNFTOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "Proposal still active");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
    }
}
