module avalon (
    input wire clk,
    input wire resetn,
    output reg valid,
    input wire ready,
    output reg [7:0] data
);

//TODO mais um estado = Stop quando não há mais dados a serem enviados.
parameter S0 = 1'b0, //Idle
          S1 = 1'b1; //Sending

/*Preciso de uma máquina de estados com dois estados. Um quando não estou enviando dados e outro quando envio.
Primeiro estado S0 = Eu vou colocar a saida valid = 0 e não importa os dados de saida
Segundo estado  S1 = Eu vou levantar valid e já começo a transmissão de dados.
Os estados vão mudar com o sinal ready. Assim que perceber um alto em ready, no próximo ciclo eu subo valid e começo
a transmissão. 
*/

//Dados a serem enviados
reg [7:0] data_to_send [0:2];
initial begin
    data_to_send[0] = 8'd4;
    data_to_send[1] = 8'd5;
    data_to_send[2] = 8'd6;
end

//Se acabar os dados de envio eu volto para idle.

//Contador para saber qual dado devo enviar
reg [2:0] counter;

reg [1:0] state_machine;

//Logica principal. O que vou fazer em cada estado.
always @(posedge clk, negedge resetn)begin
    if(~resetn) begin
        counter <= 0;
        valid  <= 0;
        data <= 8'bxxxxxxxx;
        state_machine <= S0;
    end
    else
        case (state_machine)
            S0: begin
                data <= 8'bxxxxxxxx;
                valid <= 0;
                counter <= counter;
                //Logica do prox estado
                if(ready && (counter < 3))begin
                    state_machine <= S1;
                    data <= data_to_send[counter];
                    valid <= 1;
                    counter <= counter + 1;
                end
                else begin
                    state_machine <= S0;
                end
            end
            S1: begin
                data <= data_to_send[counter];
                valid <= 1;
                counter <= counter + 1;
                //Logica do prox estado
                if (ready && (counter < 3))begin
                    state_machine <= S1; //Continua
                end
                else  begin
                    state_machine <= S0; //Volta
                    data <= 8'bxxxxxxxx;
                    valid <= 0;
                    counter <= counter;
                end
            end
        endcase
end

endmodule

