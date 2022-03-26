import "./system__NuggftV1Loan.t.sol";
import "./system__NuggftV1Swap.t.sol";
import "./system__NuggftV1Epoch.t.sol";
import "./system__one.t.sol";

contract System is system__NuggftV1Swap, system__one, system__NuggftV1Loan, system__NuggftV1Epoch {
    function setUp() public {
        forge.vm.roll(14069560);

        // dep.init();
        processor = IDotnuggV1Safe(address(new DotnuggV1()));
        nuggft = new RiggedNuggft(address(processor));
        // record.build(nuggft.external__agency__slot());

        _nuggft = address(nuggft);

        expect = new Expect(_nuggft);

        _processor = address(processor);

        _migrator = new MockNuggftV1Migrator();

        users.frank = address(uint160(uint256(keccak256("frank"))));
        forge.vm.deal(users.frank, 90000 ether);

        users.dee = address(uint160(uint256(keccak256("dee"))));
        forge.vm.deal(users.dee, 90000 ether);

        users.mac = address(uint160(uint256(keccak256("mac"))));
        forge.vm.deal(users.mac, 90000 ether);

        users.dennis = address(uint160(uint256(keccak256("dennis"))));
        forge.vm.deal(users.dennis, 90000 ether);

        users.charlie = address(uint160(uint256(keccak256("charlie"))));
        forge.vm.deal(users.charlie, 90000 ether);

        users.safe = address(uint160(uint256(keccak256("safe"))));
        forge.vm.deal(users.safe, 90000 ether);

        forge.vm.startPrank(0x9B0E2b16F57648C7bAF28EDD7772a815Af266E77);
        nuggft.setIsTrusted(users.safe, true);
        forge.vm.stopPrank();
    }
}
