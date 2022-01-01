// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/* 

    Descripción: Un producto financiero tokenizado llamado "Dynamite".
    A medida que se incremente el valor total y el tiempo, aumentará el APR y con el 
    la probabilidad de explotar, en caso de explosión se pierde el 50% del staking.
    
    El objetivo del usuario será obtener el mayor beneficio posible, tomando
    el riesgo que considere, a mayor tiempo/apr/probabilidad, mayor riesgo.

*/ 

    contract Dynamite {

        struct user{
            uint256 cantidad;
            uint256 profit;
            uint256 time;
        }

        modifier isOwner(){
            require(msg.sender == owner, "Acceso no autorizado");
            _;
        }

        address private owner;
        uint256 private prob;
        uint256 private tiempo; //256 porque almacena block.timestamp
        uint256 private apr=100;
        bool private game;
        mapping(address => user) public users;

        constructor() payable{
            require(address(this).balance >= 100000000);
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
                users[msg.sender].profit = 0;

            }else{
                users[msg.sender].time = block.timestamp-users[msg.sender].time;
                users[msg.sender].profit = makeBeneficio();
            }
        }

        function harvest(address payable _address) external{

            makeBeneficio();
            require(users[msg.sender].cantidad != 0);
            require(users[msg.sender].profit != 0);

            _address.transfer(users[msg.sender].profit);
            users[msg.sender].profit = 0;
        }

        function unstake(address payable _address) external{

            makeBeneficio();
            require(users[msg.sender].cantidad != 0);

            _address.transfer(users[msg.sender].profit + users[msg.sender].cantidad);
            users[msg.sender].profit = 0;
            users[msg.sender].cantidad = 0;
            users[msg.sender].time = 0;


        }

        /* Dynamite functions */

        function dynamite() external{

            aumentoProb();
            aumentoApr();
            makeBeneficio();

            if(makeRandomnum()<=aumentoProb()){
                explosion();
            }
        
        }

        function explosion() private isOwner{
            require(game == true);
            users[msg.sender].profit /= 2;
            users[msg.sender].cantidad /= 2;
            prob=0;
            tiempo=90; 
            apr=100;
            game = false;
        }

        function nuevaBomba() external isOwner{ 
            require(address(this).balance >= 100000000); // 100000000000000000 = 0.1BNB
            require(game == false);
            tiempo=block.timestamp-90; // sale con 90 seg para que haya un 1% de apr
            game = true;
        }

        function aumentoApr() private returns(uint256){ // 5 Dias en segundos = 432000 / 90 = 4800% apr, o 1 seg /9 
            apr = (makeTiempoDeBomba()/90);
            return apr;
        }

        function aumentoProb() private returns(uint256){ 
            prob = makeTiempoDeBomba()/110; // Si tiempo = 432000 habra un 50% (432000 = 5 dias)8600
            return prob;
        }

        /* Utilities */

        function makeBeneficio() private returns(uint256){
            users[msg.sender].profit = (((users[msg.sender].cantidad/100)*apr)/525600)*(block.timestamp-users[msg.sender].time);
            return users[msg.sender].profit;
        }

        function makeRandomnum() private view returns(uint256){
            return uint(keccak256(abi.encodePacked(block.difficulty, msg.sender, address(this), block.timestamp, block.gaslimit, block.number, block.coinbase)))%100;
        }

        function makeTiempoDeBomba() private view returns(uint256){
            require(game == true);
            return block.timestamp-tiempo;
        }

        /* Getters */

            //User

        function getMiBalanceBomb() external view returns(uint256){
            return users[msg.sender].cantidad;
        }

        function getMiBeneficioBomb() external view returns(uint256){
            return users[msg.sender].profit;
        }
        
        

            //Bomb

        function getProb() external view returns(uint256){
            return prob;
        }

        function getApr() external view returns(uint256){
            return apr;
        }

        function getBombTime() external view returns(uint256){
            return makeTiempoDeBomba();
        }

        function getGame() external view returns(bool){
            return game;
        }

    }
