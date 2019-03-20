# 多轮闲聊模型文档

## 数据

数据分为三个部分：微博对话数据、训练词表、词向量，均在`data/`目录下。

### 微博对话数据

微博上的session级对话数据，连续的几行属于一个对话，多段对话之间使用空行隔开，保存在`weibo.data`中。对话的形式保证是两个人交替说话，即`ABAB...`的形式，句子仅包含汉字和标点符号，已使用中文分词工具`jieba`分词（官方文档https://github.com/fxsjy/jieba），不同的词之间用空格分隔。统计信息如下：

| sessions | sentences per session | words per sentence | unique words | Distinct-1(%) | Distinct-2(%) | Distinct-3(%) | Distinct-4(%) |
|---|---|---|---|---|---|---|---|
| 587712 | 3.55 | 7.84 | 256830 | 1.5 | 18.9 | 51.3 | 75.8 |

`Distinct-n`：计算文本中不重复的`ngram`数目的占比，$Distinct-n=\frac{Count(unique\ ngram)}{Count(total\ ngram)}$

为了防止出现`dominating learning`的问题，这里保证了完全相同的句子出现次数不超过50。

###训练词表

在对话数据的整体词表中，选取了词频超过10的词，以及训练中用到的特殊字符`<UNK>`，`<GO>`，`<EOS>`，`<PAD>`（按这个顺序出现在词表的最前面），保存在`wordlist.data`中，共有41815个。下面简要介绍特殊字符的含义：

- `<UNK>`：为了减小词表的大小，对于词频过小的词（不超过10），用统一的符号`<UNK>`来表示

- `<GO>`：在训练中表示一个句子的开始

- `<EOS>`：在训练中表示一个句子的结束

- `<PAD>`：在做`mini_batch`的过程中用来做padding的字符

###词向量

在900万语料上训练的词向量，保留了在训练词表中出现的词的100维表示，见`wordvector.data`。在训练时，如果在词向量表中，则前100维使用其中的词向量，剩余的部分随机初始化；如果不在词向量表中，则全部重新初始化。

## 模型介绍

基于HRED模型，详情见`Build End-To-End Dialogue Systems Using Generative Hierarchical Neural Network Models`。下面做简要介绍。

### 模型框架

![模型框架图](C:\Users\fansy\Desktop\捷通初步交付\模型框架图.png)

- Word Level Encoder的输入为每个词的`embedding`表示，$h_{i,j}=f(h_{i,j-1},w_{i,j})$，其中$h_{i,j}$表示第$i$个句子encode到第$j$个词时的隐状态，$w_{i,j}$是第$i$个句子第$j$个词的`embedding`表示，采用了GRU来做encoder。
- Utterance Level Encoder的输入为每个句子的Word Level Encoder最后时刻的隐状态$h_{i,n_i}$，encoder的公式为$l_i=f(l_{i-1},h_{i,n_i})$，其中，$n_i$表示第$i$个句子的词数，$l_i$表示encode到第$i$个句子时的上下文隐状态。
- Decoder中隐状态的计算公式为$s_t=f(e_{y_{t-1}},s_{t-1},c_t)$，其中$s_t$表示解码第$t$个词时的隐状态，$y_t$表示第$t$个时刻解码出的词，$e_{y_{t-1}}$表示上个时刻解码结果的`embedding`，$c_t$表示时刻$t$时第$m$个句子（最后一句）的Word Level Encoder对每个时刻的输出做Word Level Attention的结果，这里用的是Luong Attention。那么时刻$t$词表中的词的分布概率$p(y_t|c_t,y1,...,y_{t-1})=softmax(Wo_t)$，其中，$o_t$是Decoder在时刻$t$的输出，$W$是投影矩阵。

###模型参数

- Word Level Encoder,Utterance Level Encoder和Decoder都采用的是GRU，隐层大小`hidden_size`为512。
- `batch_size`为64。
- `learning_rate`初始值为1e-4（过高会影响实验结果）。
- 词向量的`embedding_size`为200。
- Decoder在做inference的时候，句子的最长长度`max_sent_len`为50。

## 实验结果

在数据中随机选取了2000轮对话作为测试集，做teach forcing的decode得到的结果计算**perplexity**为**110.1**，用greedy和beam search的方式分别做inference，得到的结果统计数据如下：

|             | Distinct-1(%) | Distinct-2(%) | Distinct-3(%) | Distinct-4(%) | 句子平均词数 |
| ----------- | ------------- | ------------- | ------------- | ------------- | ------------ |
| Greedy      | 4.4           | 20.1          | 41.1          | 59.0          | 6.861        |
| Beam search | 4.1           | 16.5          | 32.3          | 46.4          | 5.732        |

其中，beam search的beam width设为20，长度惩罚项为0，即不对长度进行惩罚。可以看到，在`Distinct-n`和句子平均词数上，使用greedy的inference更有一些，不过在实际观察中，beam search的结果往往语法性更好(语法性也比较难用自动指标来衡量)。由于beam search的搜索空间更大，解码的耗时上会比greedy的解码方式耗时更多，占用的空间也会更大一些，在这里仅作为一种可能的解码选择。

### 一些例子

