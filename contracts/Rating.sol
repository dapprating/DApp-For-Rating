pragma solidity 0.5.16;

contract Rating {
    
    address key;
    constructor(address _key) public { key = _key; }
    
    struct resourceRating {
        uint256 likes;
        uint256 dislikes;
    }

    string[] public resources;
    mapping(string => resourceRating) public resourcesInformation;
    mapping(string => bool) public ratedResources;
    mapping(bytes32 => mapping(string => bool)) public ratingsInformation;
    mapping(bytes32 => mapping(string => bool)) public usersToResources;
    
    modifier validCredentials(bytes32 _cred, bytes memory sig) {
        require(recoverSigner(keccak256(abi.encodePacked(_cred)), sig) == key, 'Invalid credentials.');
        _;
    }

    function rate(
        bytes32 _cred,
        string memory _res,
        bool _vote, 
        bytes memory _sig
    ) 
        public
        validCredentials(_cred, _sig)
    {
        if (usersToResources[_cred][_res] == true) {
            if (
                ratingsInformation[_cred][_res] == true &&
                _vote == false
            ) {
                ratingsInformation[_cred][_res] = false;
                resourcesInformation[_res].likes -= 1;
                resourcesInformation[_res].dislikes += 1;
            }
            if (
                ratingsInformation[_cred][_res] == false &&
                _vote == true
            ) {
                ratingsInformation[_cred][_res] = true;
                resourcesInformation[_res].likes += 1;
                resourcesInformation[_res].dislikes -= 1;
            }
        } else {
            if (ratedResources[_res] == false) {
                ratedResources[_res] = true;
                resources.push(_res);
                usersToResources[_cred][_res] = true;
                if (_vote == true) {
                    resourcesInformation[_res] = resourceRating(1, 0);
                    ratingsInformation[_cred][_res] = true;
                } else {
                    resourcesInformation[_res] = resourceRating(0, 1);
                    ratingsInformation[_cred][_res] = false;
                }
            } else {
                usersToResources[_cred][_res] = true;
                if (_vote == true) {
                    resourcesInformation[_res].likes += 1;
                } else {
                    resourcesInformation[_res].dislikes += 1;
                }
            }
        }
    }

    function getResourceInformation(string memory _resourceID)
        public
        view
        returns (uint256, uint256)
    {
        return (
            resourcesInformation[_resourceID].likes,
            resourcesInformation[_resourceID].dislikes
        );
    }

    function getNumberOfRatedResources() public view returns (uint256) {
        return resources.length;
    }

    function getRatedResource(uint256 _index)
        public
        view
        returns (string memory)
    {
        return resources[_index];
    }
    
    function recoverSigner(bytes32 message, bytes memory sig)
       public
       pure
       returns (address)
    {
       uint8 v;
       bytes32 r;
       bytes32 s;
       (v, r, s) = splitSignature(sig);
       return ecrecover(message, v, r, s);
    }
    
    function splitSignature(bytes memory sig)
       public
       pure
       returns (uint8, bytes32, bytes32)
    {
       require(sig.length == 65);
       bytes32 r;
       bytes32 s;
       uint8 v;
       assembly {
           r := mload(add(sig, 32))
           s := mload(add(sig, 64))
           v := byte(0, mload(add(sig, 96)))
       }
       return (v, r, s);
    }
}