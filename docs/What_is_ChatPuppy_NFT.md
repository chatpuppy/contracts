
我们在设计`ChatPuppy NFT`时，考虑需要解决以下几个问题：

* 如何让NFT的特征更有趣，随机性更强，更好玩
* 如何让NFT的属性可信度更高
* 如何让NFT的铸币机制更去中心化
* 如何让NFT的价值更得到保障，不被篡改
* 如何让NFT的交易变得更加简单
* 如何让NFT的通用性更强，可以接入第三方平台，如`OpenSea`，`LooksRare`等

为了解决上述问题，我们采用`ChainLink VRF`随机数发生机制，通过智能合约在链上生成随机的道具属性元数据（metadata），并以此元数据来确定`NFT`的图像，等级等属性。

这种机制与现有流行的由发行方铸造NFT，然后为每个NFT人为的设置`Metadata`的中心化方式不同，他是一种去中心化的，公平的，可信的NFT生成方案。

本文旨在介绍该技术解决方案，程序员可以通过了解`ChatPuppy NFT`的实例，设计出各种各样的NFT创新产品。

## 1. ChatPuppy NFT系统结构
`ChatPuppy NFT`系统由以下几个模块组成：

### 1.1 铸造模块（Mint）
任何人可以在支付少量`ETH`情况下，购买`NFT盲盒`（Mystery Box），该盲盒在标准`ERC721`协议基础上，增加了随机元数据生成的功能。在盲盒开启前，元数据为0，执行开盲盒动作（`unbox`）后，才会随机的确定该NFT的元数据值（即该NFT的属性值）。

当用户购买一个盲盒后，通过合约的`tokenMetaData`属性，得到该盲盒NFT的`artifacts`值为0，当运行`unbox`方法后，再次调用`tokenMetadata`属性，会看到`artifacts`变成了类似`0x05460006010607060306`的值。这就是该NFT的元数据，这个元数据是通过`ChainLink VRF`在链上原始生成的，具有不可篡改的特点。

智能合约开发人员可以自行定义该元数据结构，定义元数据的合约为：[ItemFactory合约](https://github.com/chatpuppy/contracts/blob/main/contracts/lib/ItemFactory.sol)。合约部署后，开发人员可以通过该合约的`addBoxType`和`addItem`定义出具有各种灵活属性的NFT。

### 1.2 账户管理模块（Profile）
![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0akf1etipj223q0t4n5k.jpg)
该模块用于管理和显示用户钱包中的NFT，具有如下功能：
* 显示NFT的`TokenId`，图像，等级(Level)，经验值(Exp)以及元数据
* 出售(Sell)拥有的NFT

### 1.3 交易市场模块（Marketplace）
![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0akvzoke9j21qm0u07b8.jpg)
该模块用于在交易市场中流通NFT，具有如下功能：
* 显示NFT的`TokenId`，图像，等级，经验值，价格
* 购买NFT
* 更新已挂卖的NFT的价格
* 撤销已经挂卖的NFT

### 1.4 NFT应用模块（Dapp）
即在`ChatPuppy Dapp`聊天应用中使用头像，不同等级（Lvl）和经验值（Exp）的NFT会拥有不同的功能。

## 2. NFT的特征表

### 2.1 特征Traits
每个`ChatPuppy NFT`由六个特征（Traits）组成，分别为：
* 背景（Background）
* 身体（Body）
* 眼镜（Eyes）
* 盔甲（Fur）
* 头（Head）
* 嘴巴（Mouth）

每个特征拥有不同的`道具（Item）`，每个道具具有不同的`稀有度（Rarity）`，`等级（Level）`和`经验值（Experience）`。

通过链上随机数机制，生成不同的特征组合，产生高达10万种不同的`ChatPuppy NFT`，每个NFT都具有不同的稀有度，等级，以及经验值。

### 2.2 ChatPuppy各个特征的属性列表

|特征ID|特征名称|道具ID|道具名称|稀有度|等级|经验值|说明|
|-:|:-|-:|:-|-:|-:|-:|-:|
|2|Background|1|Blue|28%|1|0|
|2|Background|2|Orange|23%|1|20|
|2|Background|3|Purple|19%|1|50|
|2|Background|4|Red|15%|1|85|
|2|Background|5|Green|10%|1|180|
|2|Background|6|Grey|5%|1|460|
|3|Body|1|Gakuran|33%|1|0|
|3|Body|2|Bandana|12%|1|175|
|3|Body|3|Tropical|15%|1|120|
|3|Body|4|Hoodie|14%|1|135|
|3|Body|5|Stonks|10%|1|230|
|3|Body|6|Casual|16%|1|110|
|4|Eyes|1|Normal|30%|1|0|
|4|Eyes|2|Bored|13%|1|130|
|4|Eyes|3|Laser|6%|1|400|
|4|Eyes|4|Glasses1|9%|1|235|
|4|Eyes|5|Glasses2|11%|1|170|
|4|Eyes|6|Glasses3|16%|1|90|
|4|Eyes|7|Glasses|15%|1|100|
|5|Head|1|Plumber|6%|1|530|
|5|Head|2|Halo|6.5%|1|480|
|5|Head|3|Mohawk|7%|1|440|
|5|Head|4|Rainbow|9%|1|320|
|5|Head|5|Helmet|9.5%|1|300|
|5|Head|6|Top|7.5%|1|400|
|5|Head|7|Wizard|6.5%|1|480|
|5|Head|8|Crown|2.5%|1|1420|
|5|Head|9|Pirate|4%|1|850|
|5|Head|10|Space|3.5%|1|1000|
|5|Head|11|None|38%|1|0|
|6|Fur|1|Grey|37%|1|0|
|6|Fur|2|Green|16%|1|130|
|6|Fur|3|Brown|12%|1|210|
|6|Fur|4|Gold|6%|1|520|
|6|Fur|5|Purple|13%|1|180|
|6|Fur|6|Pink|16%|1|130|
|7|Mouth|1|Bone|18%|1|70|
|7|Mouth|2|Grrrrr|31%|1|0|
|7|Mouth|3|Soother|16%|1|95|
|7|Mouth|4|Beard|15%|1|110|
|7|Mouth|5|Mask|8%|1|290|
|7|Mouth|6|Gold|12%|1|160|

注意：
* 上述每个特征的所有道具稀有度之和必须为`100%`
* 经验值和稀有度大概成反比
* 经过排列，以上一共可以产生NFT数量为：`6 * 6 * 7 * 11 * 6 * 6 = 99792`个

### 2.3 特征值上链
上表中的数据，我们在脚本中通过`javascript`用以下代码实现，并将其写入`ItemFactory`合约中：
```
export const itemParams = [{
		boxType: 2,
		boxName: 'Background',
		itemId: 1,
		itemName: 'Blue',
		rarity: 280000,
		level: 1,
		experience: 0,
	}, {
		boxType: 2,
		boxName: 'Background',
		itemId: 2,
		itemName: 'Orange',
		rarity: 230000,
		level: 1,
		experience: 20,
	}, {
		...
	}, {
		boxType: 7,
		boxName: 'Mouth',
		itemId:  6,
		itemName: 'Gold',
		rarity:  120000,
		level:   1,
		experience: 160,
	}
];
```
这些数值一次性定义并写入区块链，无法篡改。

完整的配置脚本请[参考这里](https://github.com/chatpuppy/contracts/blob/main/scripts/5_test_item_factory.js)

## 3. 如何从Metadata推算出特征值，等级与经验值
以元数据属性`05460006010607060306`为例，根据这个元数据，结合上述属性表，可以得出头像，等级，经验值等数据，见下图：

```
0546 0006 01 06 07 06 03 06
|    |    |  |  |  |  |  |
|    |    |  |  |  |  |  └——Background#6
|    |    |  |  |  |  └——Body#3
|    |    |  |  |  └——Eyes#6
|    |    |  |  └——Head#7
|    |    |  └——Fur#6
|    |    └——Mouth#1
|    └——Level=0x0006=6
└——Experience=0x0546=1350
```

通过查询上表，得到：
|特征|道具ID|Lvl|Exp|
|:-|:-|:-|:-|
|Background|6|1|460|
|Body|3|1|120|
|Eyes|6|1|90|
|Head|7|1|480|
|Fur|6|1|130|
|Mouth|1|1|70|
|合计||6|1350|

即该NFT的等级为`6`，经验值Exp为`1350`（即十六进制`0x0546`），在用户NFT列表和交易市场中，以如下呈现：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0am74935lj20g80rqdht.jpg)

为了NFT资产的属性安全，防止技术人员在前端恶意篡改属性值，我们在合约中进行计算，并将等级和经验值写在链上。

## 4. 关于NFT稀有度，经验值Exp的范围计算
### 4.1 算法
为了帮助用户了解`ChatPuppy NFT`的属性并对自己开盲盒得到的NFT进行价值评估，对NFT的稀有度做如下计算：

每个NFT的稀有度为6个特征值的乘积，以上述元数据属性`05460006010607060306`为例，通过查询上述稀有度表，得到：

|特征|道具ID|稀有度|
|:-|:-|:-|
|Background|6|5%|
|Body|3|15%|
|Eyes|6|16%|
|Head|7|6.5%|
|Fur|6|16%|
|Mouth|1|18%|
|||概率：0.0000022464|

即该NFT的出现概率为`百万分之2.2464`。

### 4.2 最稀有的NFT
经过计算，出现概率最低的（也就是最稀有）是：`0.0000000360`，即`一亿分之3.6`。可以推算出，对应的`metadata`是：`0x0CF80006050408030506`

即：
|特征|道具ID|稀有度|Exp|
|:-|:-|:-|:-|
|Background|6|5%|460|
|Body|5|10%|230|
|Eyes|3|6%|400|
|Head|8|2.5%|1420|
|Fur|4|6%|520|
|Mouth|5|8%|290|
|||概率：0.0000000360|Exp：3320=0x0CF8|

### 4.3 最普通的NFT
出现概率最高的是：`0.001208204`，即`0.1208%`。对应的`metadata`为：`0x0000000602010b010101`。

即：
|特征|道具ID|稀有度|Exp|
|:-|:-|:-|:-|
|Background|1|28%|0|
|Body|1|33%|0|
|Eyes|1|30%|0|
|Head|11|38%|0|
|Fur|1|37%|0|
|Mouth|2|31%|0|
|||概率：0.001208204|Exp：0|

### 4.4 稀有度与Exp概率分布
笔者根据上述特征值，进行16000多次模拟，得出如下分布频率曲线：

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0b22tru6aj20yy0m8dhb.jpg)
上图是Experience的分布频率。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0b29c46fnj20yy0m8gmz.jpg)
上图是Experience的分布频率帕累托图，Exp: 350-1300之间站到80%左右。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0b24e3skqj20yy0m8abl.jpg)
上图是稀有度Rarity的分布频率。

![](https://tva1.sinaimg.cn/large/e6c9d24egy1h0b2crmuz5j20yw0m8dh5.jpg)
上图是稀有度Rarity的分布频率帕累托图，66%的落在0-500之间，即百万次重复次数0-500。

## 5. 关于链上随机数机制
上述实现方案的关键步骤是如何在合约中生成随机数，产生元数据属性。感谢`ChainLink`为我们提供了基于`VRF`（可验证随机函数）的随机数方案，让我们能直接链上产生随机数，从而让NFT的铸造变得更有趣，更可信，真正实现了去中心化。

最近，`ChainLink`推出了`VRF V2`版本，将随机数使用的门槛大幅度降低。[参考这里](https://docs.chain.link/docs/chainlink-vrf/)

如何在合约中调用并实现NFT的随机性，请参考笔者写的智能合约[ChatPuppyNFTManagerV2合约](https://github.com/chatpuppy/contracts/blob/main/contracts/ChatPuppyNFTManagerV2.sol)

## 6. NFT元数据（Metadata）的原生性
目前，大多数在`OpenSea`等NFT交易平台上交易的NFT的商业模式基本上是：发行方统一发行几千上万个NFT，然后在`Opensea`上开一个商铺（Collection），将这些NFT上架并开始销售。

大多数NFT的元数据并不写在区块链上，而是写在发行方的服务器上，或者通过IPFS索引到某个数据库。只要发行方需要，可以随时修改这些NFT的元数据属性，从而可能让一些高属性或稀缺的NFT变得一文不值，或者让垃圾NFT变得价值连城。

除此之外，很多`GameFi`游戏也通过在服务器上生成NFT道具的随机属性。这些模式本质上是中心化的，也正因此，目前这些主流的方式一直在遭到诟病，并导致NFT的资产价值得不到真正的保护。

解决这个问题的关键是如何在链上直接生成NFT属性，我们很高兴的看到`Loot`项目提出了一个很有意思的解决框架，即发行方自定义NFT的特征值。但是`Loot`的特征值仍旧由发行方定义。

`ChatPuppy NFT`通过`ChainLink`的随机数预言机，在链上定义特征值，从而为NFT以及`GameFi`提供了新的解决方案。

