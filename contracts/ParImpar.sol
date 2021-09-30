pragma solidity >=0.4.25 <0.6.0;

import "./SimpleCommit.sol";

contract parImpar {

 

using SimpleCommit for SimpleCommit.CommitType;

 


// Estados: aguardaJogador, revelaValores12, revelado, Fim....

 

SimpleCommit.CommitType valorDono;
SimpleCommit.CommitType valorJogador;

 

address payable dono;
address payable jogador;

 

uint256 valorAposta;
uint256 limiteBloco;

 

// flags!!!!!


function setValorAposta() internal{
    valorAposta = msg.value;
}


constructor (bytes32 _vD) public {
    valorDono.commit(_vD);
    setValorAposta();
    limiteBloco = block.number + 10; //????
    dono =msg.sender;
    // armazena estado
}

 


modifier somenteDono {require (msg.sender == dono,"Somento o dono pode chamar esta funcao!");_;}
modifier capValue {require ( msg.value >= valorAposta,"fala alguma coisa");_;}

function entraJogo(bytes32 _vJ) public {
//   require estado....
    
    valorJogador.commit(_vJ);
  // atualiza estado do contrato  
}

 

function donoRevela(bytes32 nonce1, byte _v1) public  {
  // require dono
//   require estado...
  valorDono.reveal(nonce1,_v1);
  //ok = sc1.isCorrect();
}

 

// function jogadorRevela(....) public {.....}

 


// function pagaVencedor() public {
// Quem é o vencedor???
// *** verificar bloco limite ***
// Se bloco passou o limite e ninguem revelou ???
// Se o jogador revelou corretamente e o dono nao: jagador ganha e é pagaVencedor
// Se dono......

 

// Se ambos revelaram junte o valor com valorDono.getValue() e valorJoador.getValue() e determine o vencedor
  
//}
}