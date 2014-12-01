/*--显示BOM层级-------------
CreatedOn:2013.10.23 11:00
-----------------*/
WITH BOM_CTE
(
	ParentId,	--父项
	ChildId,	--子项
	Qty,		--子项数量
	QtyTotal,	--总用量（父项数量*子项数量）
	Unit,		--计量单位
	Layer,		--层级
	Sort,		--排序
	CreatedOn,	--创建日期
	TopLayer,	--顶层（产品）
	Name,		--子项名称
	Lev			--文字描述顺序(父项->子项1-子项2-...)
)		
AS
(						
	SELECT	ParentId,	
			ChildId,	
			Qty,	
			QtyTotal = Qty ,
			Unit,
			-1 AS Layer,	
			Convert(varchar(255),ChildId) AS Sort,	
			CreatedOn,
			ChildId	--这里是顶层的占位
			,Name
			,Convert(varchar(255),Name)
	FROM	BOM	E --基础部分
	WHERE ParentId IS  NULL	--顶层
	UNION ALL					
	SELECT	R.ParentId,	
			R.ChildId,	
			R.Qty,
			CAST(R.Qty*CTE.QtyTotal AS decimal(18,3)),
			R.Unit,	
			Layer+1,	
			CONVERT(VARCHAR(255),ltrim(rtrim(Sort))+'->'+ltrim(rtrim(R.ChildId))),	
			R.CreatedOn	,
			TopLayer,	--和参数TopLayer要一致
			R.Name,
			CONVERT(varchar(255),R.Name+'->'+Lev)
	FROM	BOM	R  --循环部分		
	INNER JOIN	BOM_CTE	CTE ON	R.ParentId=CTE.ChildId
) 

SELECT	ROW_NUMBER ()over(order by Sort)as Num,	--序号
		Layer,	--层级
		REPLICATE('.',Layer)+convert(varchar(10),Layer) AS ExL ,	--展开层
		ParentId,	--父项
		ChildId,	--子项
		Qty,
		QtyTotal,
		Unit,	
		CreatedOn,	
		Sort,
		TopLayer,	--和参数TopLayer要一致才能出现顶层物料（即父项为null的）
		Name,
		Lev
FROM	BOM_CTE 
--创建数据表及插入测试数据 开始--
--CreatedOn：2013.12.13 08:55
CREATE TABLE [dbo].[BOM] (
	[ParentId] [char](18) NULL
	,[ChildId] [char](18) NULL
	,[Qty] [decimal](18, 3) NULL
	,[Unit] [char](3) NULL
	,[CreatedOn] [datetime2](0) NULL
	,[Name] [nvarchar](120) NULL
	) ON [PRIMARY]
GO
INSERT INTO BOM VALUES('P1','C1','1','EA',GETDATE(),'P1的子项C1')
INSERT INTO BOM VALUES('P1','C2','1','EA',GETDATE(),'P1的子项C2')
INSERT INTO BOM VALUES('P1','C3','2','EA',GETDATE(),'P1的子项C3')
INSERT INTO BOM VALUES('C1','D1','2','EA',GETDATE(),'C1的子项D1')
INSERT INTO BOM VALUES('D1','E1','2','EA',GETDATE(),'D1的子项E1')
INSERT INTO BOM VALUES(NULL,'P1','1','EA',GETDATE(),'P1是顶层')
--创建数据表及插入测试数据 结束--