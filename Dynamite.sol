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
            uint256 beneficio;
            uint256 time;
        }

        modifier isOwner(){
            require(msg.sender == owner, "Acceso no autorizado");
            _;
        }

        address private owner;
        uint256 private prob;
        uint256 private num_rand; 
        uint256 private tiempo;
        uint256 private apr;
        bool private game;
        mapping(address => user) private users;

        constructor() payable{
            owner = msg.sender;
            game = false;
        }

        function actualizar() public{ // funcion para pruebas
            if(game == true){
                dynamite();
            }else{
                nuevaBomba();
            }
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
                users[msg.sender].beneficio = makeBeneficio();
                users[msg.sender].time = block.timestamp;
            }
        }

        function harvest(address payable _address) external{

            makeBeneficio();
            require(users[msg.sender].cantidad != 0);
            require(users[msg.sender].beneficio != 0);

            _address.transfer(users[msg.sender].beneficio);
            users[msg.sender].beneficio = 0;
        }

        function unstake(address payable _address) external{

            makeBeneficio();
            require(users[msg.sender].cantidad != 0);

            _address.transfer(users[msg.sender].beneficio + users[msg.sender].cantidad);
            users[msg.sender].beneficio = 0;
            users[msg.sender].cantidad = 0;
            users[msg.sender].time = 0;
        }

        /* Dynamite functions */

        function dynamite() private{

            require(game==true);

            makeBeneficio();
            aumentoApr();
            aumentoProb();
            getRandomnum();

            if(getRandomnum()<=aumentoProb()){
                explosion();
            }
        
        }

        function explosion() private{
            require(game == true);
            users[msg.sender].beneficio /= 2;
            users[msg.sender].cantidad /= 2;
            prob=0;
            tiempo=90; 
            apr=0;
            game = false;
        }

        function nuevaBomba() public isOwner{ // Debe ser external, public para pruebas desde actualizar
            require(game == false);
            tiempo=block.timestamp-90; // sale con 90 seg para que haya un 1% de apr
            game = true;
            dynamite();
        }

        function aumentoApr() private returns(uint256){ // 5 Dias en segundos = 432000 / 90 = 4800% apr, o 1 seg /9 
            apr = (makeTiempoDeBomba()/90)+30;
            return apr;
        }

        function aumentoProb() private returns(uint256){ 
            prob = makeTiempoDeBomba()/8600; // Si tiempo = 432000 habra un 50% (432000 = 5 dias)
            return prob;
        }

        /* Others */

        function makeBeneficio() private returns(uint256){
            users[msg.sender].beneficio = (((users[msg.sender].cantidad/100)*apr)/525600)*(block.timestamp-users[msg.sender].time);
            return users[msg.sender].beneficio;
        }

        function getRandomnum() private returns(uint256){
            num_rand = uint(keccak256(abi.encodePacked(block.difficulty, msg.sender, address(this), block.timestamp, block.gaslimit, block.number, block.basefee, block.coinbase)))%100;
            return num_rand;
        }

        function makeTiempoDeBomba() public view returns(uint256){ // Debe ser public porque interesa llamarla desde la web y desde el contrato
            require(game == true);
            return block.timestamp-tiempo;
        }

        /* Getters */

            //User

        function getMiBalanceBomb() external view returns(uint256){
            return users[msg.sender].cantidad;
        }

        function getMiBeneficioBomb() external view returns(uint256){
            return users[msg.sender].beneficio;
        }

        function getMiTime() external view returns(uint256){
            if(users[msg.sender].time != 0){
                return block.timestamp-users[msg.sender].time;
            }else{
                return users[msg.sender].time;
            }
        }
        
            //Bomb

        function getProb() external view returns(uint256){
            return prob;
        }

        function getApr() external view returns(uint256){
            return apr;
        }

        function getBombTime() external view returns(uint256){
            return tiempo;
        }

        function getBalanceTotal() external view returns(uint256){
            return address(this).balance;
        }

        function getGame() external view returns(bool){
            return game;
        }

    }
