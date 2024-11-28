//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

interface IVizingSwap{
    ///event
    event VizingSwapEvent(address indexed sender, address indexed tokenIn, address indexed tokenOut,address receiver, uint256 amountIn,uint256 amountOut);


    ///struct
    struct v3ExactInputParams{
        uint256 index;
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    struct V2SwapExactTokensForTokensParams{
        uint256 index;
        uint256 amountIn;
        uint256 amountOutMin;
        address[] path;
        address recipient;
    }
}