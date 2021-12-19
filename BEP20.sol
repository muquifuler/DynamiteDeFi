// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BEP20 {
    string public name = "Dynamite";
    string public symbol = "DYM";
    uint8 public decimals = 18;

    //uint256 public totalSupply = 1000000000000000000000000; // 1 million
    uint256 public liquidity=300000000000000; //30%
    uint256 public marketing=30000000000000; //3%
    uint256 public servidores=20000000000000; //2%
    uint256 public team=10000000000000; //1%
    uint256 public airdrop=10000000000000; //1%
    uint256 public replanteo=200000000000000; //20%
    uint256 public bomba=430000000000000; // 43%

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(address contrato) {
        balanceOf[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = liquidity;
        balanceOf[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = marketing;
        balanceOf[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = servidores;
        balanceOf[0x617F2E2fD72FD9D5503197092aC168c91465E7f2] = team;
        balanceOf[0x17F6AD8Ef982297579C203069C1DbfFE4348c372] = airdrop;
        balanceOf[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = replanteo;
        balanceOf[contrato] = bomba;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

}
