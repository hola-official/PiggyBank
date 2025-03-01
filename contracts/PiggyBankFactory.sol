// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory {
    event PiggyBankCreated(
        address indexed piggyBank,
        string purpose,
        uint256 duration,
        address token1,
        address token2,
        address token3,
        address developer
    );

    /**
     * @dev Deploys a new PiggyBank contract using the `create2` opcode.
     * @param _purpose The purpose of the PiggyBank.
     * @param _duration The saving duration in seconds.
     * @param _token1 The address of the first ERC20 token.
     * @param _token2 The address of the second ERC20 token.
     * @param _token3 The address of the third ERC20 token.
     * @param _developer The address where penalty fees will be sent.
     * @param _salt A unique salt for deterministic deployment.
     * @return The address of the newly deployed PiggyBank contract.
     */
    function createPiggyBank(
        string memory _purpose,
        uint256 _duration,
        address _token1,
        address _token2,
        address _token3,
        address _developer,
        bytes32 _salt
    ) external returns (address) {
        // Deploy the PiggyBank contract using create2
        PiggyBank piggyBank = new PiggyBank{salt: _salt}(
            _purpose,
            _duration,
            _token1,
            _token2,
            _token3,
            _developer
        );

        // Emit an event with the details of the new PiggyBank
        emit PiggyBankCreated(
            address(piggyBank),
            _purpose,
            _duration,
            _token1,
            _token2,
            _token3,
            _developer
        );

        // Return the address of the new PiggyBank
        return address(piggyBank);
    }

    /**
     * @dev Computes the address of a PiggyBank contract that would be deployed with the given parameters.
     * @param _purpose The purpose of the PiggyBank.
     * @param _duration The saving duration in seconds.
     * @param _token1 The address of the first ERC20 token.
     * @param _token2 The address of the second ERC20 token.
     * @param _token3 The address of the third ERC20 token.
     * @param _developer The address where penalty fees will be sent.
     * @param _salt A unique salt for deterministic deployment.
     * @return The computed address of the PiggyBank contract.
     */
    function computeAddress(
        string memory _purpose,
        uint256 _duration,
        address _token1,
        address _token2,
        address _token3,
        address _developer,
        bytes32 _salt
    ) public view returns (address) {
        // Encode the constructor arguments
        bytes memory constructorArgs = abi.encode(
            _purpose,
            _duration,
            _token1,
            _token2,
            _token3,
            _developer
        );

        // Encode the creation code and constructor arguments
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            constructorArgs
        );

        // Compute the address using create2 formula
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        // Convert the hash to an address
        return address(uint160(uint256(hash)));
    }
}