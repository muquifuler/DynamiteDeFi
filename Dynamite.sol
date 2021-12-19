// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

    contract Dynamite {

        BEP20 token = new BEP20(address(this));

        struct user{
            uint cantidad;
            uint beneficio;
        }

        modifier isOwner(){
            require(msg.sender == owner, "Acceso no autorizado");
            _;
        }

        address owner;
        uint8 public probabilidad;
        uint8 public num_rand; // Cada 5 min sale un numero aleatorio, si es igual o menor a probabilidad la bomba explota y todos pierden un 50%
        uint256 public tiempo;
        uint256 public anio=31536000; 
        uint256 public min5=300;
        uint256 public cantidad_total=token.balanceOf(address(this));
        //uint256 public tiempomas5min=block.timestamp+5000000;
        uint256 public apr; // La ganancia cada 5 min con 100% de apr es: 0,0009645% 
        bool juego;
        mapping(address => user) public users;

        constructor() {
            owner = msg.sender;
            juego = false;
        }

        function harvest() public{
            require(juego==true);
            token.transfer(msg.sender, users[msg.sender].beneficio);
        }

        function getBeneficio() public returns(uint256){
            users[msg.sender].beneficio = (min5*users[msg.sender].cantidad)/anio;
            return users[msg.sender].beneficio;
        }

        function explosion() public{
            require(juego==true);
            juego = false;
            probabilidad=0;
            tiempo=0; 
            apr=0;
        }

        function nuevaBomba() public isOwner{
            require(juego==false);
            juego = true;
            probabilidad=0;
            num_rand=1; // Cada 5 min sale un numero aleatorio, si es igual o menor a probabilidad la bomba explota y todos pierden un 50%
            tiempo=block.timestamp; 
            apr=100; // La ganancia cada 5 min con 100% de apr es: 0,0009645% 
        }

        function getTiempoDeBomba() public view returns(uint256){
            if(juego==true){
                return block.timestamp-tiempo;
            }else{
                return 0;
            }
        }
        
        function balanceTotal() public view returns(uint256){
            return token.balanceOf(address(this));
        }
        
        function miBalance() public view returns(uint256){
            return token.balanceOf(msg.sender);
        }
    }
