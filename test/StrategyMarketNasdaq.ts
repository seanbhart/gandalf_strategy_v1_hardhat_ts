import { ContractFactory, Contract } from "@ethersproject/contracts";
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from "chai";
import { Address } from "cluster";
import { ethers } from "hardhat";


describe("StrategyFactory contract", function () {
    // `before`, `beforeEach`, `after`, `afterEach`.

    let strategyFactoryFactory: ContractFactory;
    let strategyFactory: Contract;
    let owner: SignerWithAddress;
    let addr1: SignerWithAddress;
    let addr2: SignerWithAddress;
    let addrs: SignerWithAddress[];

    before(async function () {
        // Get the ContractFactory and Signers here.
        strategyFactoryFactory = await ethers.getContractFactory("StrategyV1Factory");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        console.log("Deploying contracts with the account:", owner.address);

        strategyFactory = await strategyFactoryFactory.deploy();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await strategyFactory.owner()).to.equal(owner.address);
        });

        it("Should have a Strategy list length of 0", async function () {
            const strategyListLength = await strategyFactory.strategyListLength();
            expect(strategyListLength).to.equal(0);
        });
    });

    describe("CreateStrategy", () => {
        let strategy: Contract;
        it("Should deploy new Strategy contract", async () => {
            console.log("create Strategy");
            await strategyFactory.createStrategy("AAPL", 1624041753, 1624128153);
            const strategyAddress = await strategyFactory.strategyList(0);
            expect(strategyAddress).to.not.undefined;

            console.log("instantiate Strategy Contract object");
            strategy = await ethers.getContractAt("StrategyV1Market", strategyAddress);
            expect(strategy.address).to.not.equal("");
        });

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