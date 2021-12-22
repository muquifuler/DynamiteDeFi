// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/* 
    Descripción: Un producto financiero tokenizado llamado "Dynamite".

    A medida que se introduza valor y pase el tiempo, aumentará el APR y
    la probabilidad de explotar, en caso de explosión el usuario tendrá
    una perdida del 50% del staking.
    
    El objetivo del usuario será obtener el mayor beneficio posible, tomando
    el riesgo que considere, a mayor tiempo/apr/probabilidad, mayor riesgo.

    */ 

    contract Dynamite {

        struct user{
            uint256 cantidad;
            uint256 beneficio;
            uint256 time;
        }

        modifier isOwner(){
            require(msg.sender == owner, "Acceso no autorizado");
            _;
        }

        address private owner;
        uint256 public prob;
        uint256 public num_rand; // Cada 5 min sale un numero aleatorio, si es igual o menor a probabilidad la bomba explota y todos pierden un 50%
        uint256 private tiempo;
        uint256 public apr;
        bool public game; // Indica si la bomba esta activa
        mapping(address => user) public users;

        constructor() payable{
            owner = msg.sender;
            game = false;
        }

        /* User functions */

        function invertir() external payable{

            require(game == true);
            require(msg.sender.balance >= msg.value);
            users[msg.sender].cantidad += msg.value;
            
            if(users[msg.sender].time == 0){
                users[msg.sender].time = block.timestamp;
                users[msg.sender].beneficio = 0;
            }else{
                users[msg.sender].time = block.timestamp;
                users[msg.sender].beneficio = getBeneficio();
            }
        }

        function harvest(address payable _address) external{

            getBeneficio();
            require(users[msg.sender].cantidad != 0);
            require(users[msg.sender].beneficio != 0);

            _address.transfer(users[msg.sender].beneficio);
            users[msg.sender].beneficio = 0;
        }

        function unstake(address payable _address) external{

            getBeneficio();
            require(users[msg.sender].cantidad != 0);

            _address.transfer(users[msg.sender].beneficio + users[msg.sender].cantidad);
            users[msg.sender].beneficio = 0;
            users[msg.sender].cantidad = 0;
            users[msg.sender].time = 0;
        }

        /* Dynamite functions */

        function dynamite() public{

            require(game==true);

            getBeneficio();
            aumentoApr();
            aumentoProb();
            getRandomnum();

            if(getRandomnum()<=aumentoProb()){
                explosion();
            }
        
        }

        function percent50() public{
            
        }

        function explosion() internal{ //Debe ser internal, solo public para pruebas
            require(game == true); // Hay que poner quitarle el 50% a todos
            game = false;
            prob=0;
            tiempo=90; 
            apr=0;
            percent50();
        }

        function nuevaBomba() external isOwner{
            require(game == false);
            game = true;
            tiempo=block.timestamp-90; // sale con 90 seg para que haya un 1% de apr
            dynamite();
        }

        function aumentoApr() internal returns(uint256){ //5 Dias en segundos = 432000 / 90 = 4800% apr, o 1 seg /9 
            apr = getTiempoDeBomba()/90;
            return apr;
        }

        function aumentoProb() internal returns(uint256){ 
            prob = getTiempoDeBomba()/8600; // Si tiempo = 432000 habra un 50% 
            return prob;
        }

        /* Others */

        function getBeneficio() internal returns(uint256){
            users[msg.sender].beneficio = (((((apr/365)/24)/60)/60)*users[msg.sender].cantidad)*(block.timestamp-users[msg.sender].time);
            return users[msg.sender].beneficio;
        }

        function getRandomnum() internal returns(uint256){
            num_rand = uint(keccak256(abi.encodePacked(block.difficulty, msg.sender, address(this), block.timestamp, block.gaslimit, block.number, block.basefee, block.coinbase)))%100;
            return num_rand;// Cada segundo sale un numero aleatorio, si es igual o menor a probabilidad la bomba explota y todos pierden un 50%
        }

        function getTiempoDeBomba() public view returns(uint256){
            require(game == true);
            return block.timestamp-tiempo;
        }

        function balanceTotal() external view returns(uint256){
            return address(this).balance;
        }

        function miBalance() external view returns(uint256){
            return msg.sender.balance;
        }

        function miBalanceBomb() external view returns(uint256){
            return users[msg.sender].cantidad;
        }

        function miBeneficioBomb() external view returns(uint256){
            return users[msg.sender].beneficio;
        }
    }
