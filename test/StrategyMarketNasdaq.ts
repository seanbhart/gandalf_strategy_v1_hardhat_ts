import { ContractFactory, Contract } from "@ethersproject/contracts";
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from "chai";
import { ethers } from "hardhat";


describe("Token contract", function () {
    // `before`, `beforeEach`, `after`, `afterEach`.

    let strategyFactory: ContractFactory;
    let strategy: Contract;
    let owner: SignerWithAddress;
    let addr1: SignerWithAddress;
    let addr2: SignerWithAddress;
    let addrs: SignerWithAddress[];

    before(async function () {
        // Get the ContractFactory and Signers here.
        strategyFactory = await ethers.getContractFactory("StrategyMarketNasdaq");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        console.log("Deploying contracts with the account:", owner.address);

        strategy = await strategyFactory.deploy("AAPL", 1623990796, 1624077196);
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await strategy.owner()).to.equal(owner.address);
        });

        it("Should have an active status (true)", async function () {
            const status = await strategy.status();
            expect(status).to.equal(true);
        });
    });

    it('should pass', () => {
        console.log(owner.address);
    });

    describe("Vote", function () {
        const voteAmount = -1;
        it(`Should vote with ${voteAmount} units`, async function () {
            await strategy.vote(voteAmount);
        });

        it(`Should have 1 vote`, async function () {
            const voteReading = await strategy.readVote();
            expect(voteReading).to.equal(voteAmount);
        });
    });
});