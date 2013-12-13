/*--显示BOM层级-------------
CreatedOn:2013.10.23 11:00
-----------------*/
WITH	BOM_CTE(
			ParentId,	--父项
			ChildId,	--子项
			Qty,		--子项数量
			QtyTotal,	--总用量（父项数量*子项数量）
			Unit,		--计量单位
			Layer,		--层级
			Sort,		--排序
			CreatDate,	--创建日期
			TopLayer,	--顶层（产品）
			NAME)		--子项名称
AS(						
	SELECT	ParentId,	
			ChildId,	
			Qty,	
			QtyTotal = Qty ,
			Unit,
			-1 AS Layer,	
			Convert(varchar(255),ChildId) AS Sort,	
			CreatDate,
			ChildId	--这里是顶层的占位
			,Name
	FROM	vBOM	E --基础部分
	WHERE ParentId IS  NULL	--没有父项
	UNION ALL					
	SELECT	R.ParentId,	
			R.ChildId,	
			R.Qty,
			CAST(R.Qty*CTE.QtyTotal AS decimal(18,3)),
			R.Unit,	
			Layer+1,	
			CONVERT(VARCHAR(255),ltrim(rtrim(Sort))+'->'+ltrim(rtrim(R.ChildId))),	
			R.CreatDate	,
			TopLayer,	--和参数TopLayer要一致
			R.Name
	FROM	vBOM	R  --循环部分		
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
		CreatDate,	
		Sort,
		TopLayer,	--和参数TopLayer要一致才能出现顶层物料（即父项为null的）
		Name
FROM	BOM_CTE 