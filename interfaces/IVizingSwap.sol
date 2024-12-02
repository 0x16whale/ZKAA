//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

interface IVizingSwap {
    ///event
    event VizingSwapEvent(
        address indexed sender,
        address indexed tokenIn,
        address indexed tokenOut,
        address receiver,
        uint256 amountIn,
        uint256 amountOut
    );

    ///struct
    struct v3ExactInputParams {
        uint8 index;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct V2SwapExactTokensForTokensParams {
        uint256 index;
        uint256 amountIn;
        uint256 amountOutMin;
        address[] path;
        address recipient;
    }

    
    struct CrossParams {
        uint24 gasLimit;
        uint64 gasPrice;
        uint64 destChainId;
        uint64 minArrivalTime;
        uint64 maxArrivalTime;
        address destContract;
        address selectedRelayer;
        uint256 destChainUsedFee; // Amount that the target chain needs to spend to execute userop
        bytes batchsMessage;
        bytes packCrossMessage;
    }

    struct CrossMessage {
        uint8 way;
        uint8 index;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
}
