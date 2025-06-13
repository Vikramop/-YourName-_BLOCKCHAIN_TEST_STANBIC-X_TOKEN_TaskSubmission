const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('SessionKeyAccount', function () {
  let account, entryPoint, owner, sessionKey;

  beforeEach(async () => {
    [owner, sessionKey] = await ethers.getSigners();

    const MockEntryPoint = await ethers.getContractFactory('MockEntryPoint');
    entryPoint = await MockEntryPoint.deploy();

    const SessionKeyAccount = await ethers.getContractFactory(
      'SessionKeyAccount'
    );
    account = await SessionKeyAccount.deploy(
      owner.address,
      entryPoint.getAddress()
    );
    console.log('Deployed Contract Functions:', Object.keys(account.target));
  });

  it('Should initialize with correct owner and entry point', async () => {
    expect(await account.owner()).to.equal(await owner.getAddress());
    expect(await account.entryPoint()).to.equal(await entryPoint.getAddress());
  });

  it('Should allow owner to add and remove session keys', async () => {
    const expiry = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

    await account
      .connect(owner)
      .addSessionKey(await sessionKey.getAddress(), expiry);
    expect(await account.sessionExpiry(await sessionKey.getAddress())).to.equal(
      expiry
    );

    await account
      .connect(owner)
      .removeSessionKey(await sessionKey.getAddress());
    expect(await account.sessionExpiry(await sessionKey.getAddress())).to.equal(
      0
    );
  });

  it('Should reject non-owner from adding or removing session keys', async () => {
    const expiry = Math.floor(Date.now() / 1000) + 3600;
    await expect(
      account
        .connect(sessionKey)
        .addSessionKey(await sessionKey.getAddress(), expiry)
    ).to.be.revertedWith('not owner');
    await expect(
      account
        .connect(sessionKey)
        .removeSessionKey(await sessionKey.getAddress())
    ).to.be.revertedWith('not owner');
  });

  it('Should validate owner signatures', async () => {
    const userOp = {
      sender: await account.getAddress(),
      nonce: 0,
      initCode: '0x',
      callData: '0x',
      accountGasLimits: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [100000, 100000]
      ),
      preVerificationGas: 100000,
      gasFees: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [ethers.parseUnits('5', 'gwei'), ethers.parseUnits('10', 'gwei')]
      ),
      paymasterAndData: '0x',
    };

    const userOpHash = ethers.keccak256(
      ethers.AbiCoder.defaultAbiCoder().encode(
        [
          'address',
          'uint256',
          'bytes',
          'bytes',
          'bytes32',
          'uint256',
          'bytes32',
          'bytes',
        ],
        [
          userOp.sender,
          userOp.nonce,
          userOp.initCode,
          userOp.callData,
          userOp.accountGasLimits,
          userOp.preVerificationGas,
          userOp.gasFees,
          userOp.paymasterAndData,
        ]
      )
    );

    const signature = await owner.signMessage(ethers.toBeArray(userOpHash));
    userOp.signature = signature;

    const isValid = await account.callStatic.validateUserOpForTest(
      userOp,
      userOpHash
    );
    expect(isValid).to.equal(0);
  });

  it('Should validate active session key signatures', async () => {
    const expiry = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
    await account
      .connect(owner)
      .addSessionKey(await sessionKey.getAddress(), expiry);

    const userOp = {
      sender: await account.getAddress(),
      nonce: 0,
      initCode: '0x',
      callData: '0x',
      accountGasLimits: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [100000, 100000]
      ),
      preVerificationGas: 100000,
      gasFees: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [ethers.parseUnits('5', 'gwei'), ethers.parseUnits('10', 'gwei')]
      ),
      paymasterAndData: '0x',
    };

    const userOpHash = ethers.keccak256(
      ethers.AbiCoder.defaultAbiCoder().encode(
        [
          'address',
          'uint256',
          'bytes',
          'bytes',
          'bytes32',
          'uint256',
          'bytes32',
          'bytes',
        ],
        [
          userOp.sender,
          userOp.nonce,
          userOp.initCode,
          userOp.callData,
          userOp.accountGasLimits,
          userOp.preVerificationGas,
          userOp.gasFees,
          userOp.paymasterAndData,
        ]
      )
    );

    const signature = await sessionKey.signMessage(
      ethers.toBeArray(userOpHash)
    );
    userOp.signature = signature;

    const isValid = await account.callStatic.validateUserOpForTest(
      userOp,
      userOpHash
    );
    expect(isValid).to.equal(0);
  });

  it('Should reject expired session key signatures', async () => {
    const expiry = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
    await account
      .connect(owner)
      .addSessionKey(await sessionKey.getAddress(), expiry);

    const userOp = {
      sender: await account.getAddress(),
      nonce: 0,
      initCode: '0x',
      callData: '0x',
      accountGasLimits: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [100000, 100000]
      ),
      preVerificationGas: 100000,
      gasFees: ethers.solidityPacked(
        ['uint128', 'uint128'],
        [ethers.parseUnits('5', 'gwei'), ethers.parseUnits('10', 'gwei')]
      ),
      paymasterAndData: '0x',
    };

    const userOpHash = ethers.keccak256(
      ethers.AbiCoder.defaultAbiCoder().encode(
        [
          'address',
          'uint256',
          'bytes',
          'bytes',
          'bytes32',
          'uint256',
          'bytes32',
          'bytes',
        ],
        [
          userOp.sender,
          userOp.nonce,
          userOp.initCode,
          userOp.callData,
          userOp.accountGasLimits,
          userOp.preVerificationGas,
          userOp.gasFees,
          userOp.paymasterAndData,
        ]
      )
    );

    const signature = await sessionKey.signMessage(
      ethers.toBeArray(userOpHash)
    );
    userOp.signature = signature;

    const isValid = await account.callStatic.validateUserOpForTest(
      userOp,
      userOpHash
    );
    expect(isValid).to.equal(1);
  });
});
