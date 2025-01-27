import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract SkateAuctionToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    )
        ERC20(name_, symbol_)
    { }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
