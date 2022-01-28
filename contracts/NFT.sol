pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Verifier.sol";

contract NFT is ERC721("Win", "Win"), Verifier {

    uint256 tokenNonce;

    function mint(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) public {
        require(verifyProof(a, b, c, input), "!Proof");
        _mint(msg.sender, tokenNonce++);
    }
}
