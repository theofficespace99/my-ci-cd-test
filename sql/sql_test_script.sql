--Logic	Condition
--Admin bypass	Email in RLS_Admins
--Profit Centre security	Cost_Object = Profit_Center in STG_SECURITY_BRIDGE_ORG
--Service Portfolio security	Level_3_Reference_ID = Level_3_Reference_ID  in STG_SECURITY_BRIDGE_SP

CREATE OR ALTER FUNCTION dbo.fn_userAccessPredicate (
    @Cost_Object NVARCHAR(20),
    @Level_3_Reference_ID NVARCHAR(50)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS result
    WHERE
        -- Admins bypass RLS
        EXISTS (
            SELECT 1
            FROM dbo.RLS_Admins
            WHERE E_Mail = SESSION_CONTEXT(N'user_email')
        )
        OR
        -- Profit Centre security: Cost_Object maps to user's Profit_Center
        EXISTS (
            SELECT 1
            FROM [DIM].[STG_DIM_COST_OBJECT] co
            JOIN [SCR].[STG_SECURITY_BRIDGE_ORG] ups
                ON co.Cost_Object = ups.Profit_Center
            WHERE 
                co.Cost_Object = @Cost_Object
                AND ups.Email_ID = SESSION_CONTEXT(N'user_email')
        )
        OR
        -- Service Portfolio security: Level_3_Reference_ID match
        EXISTS (
            SELECT 1
            FROM [SCR].[STG_SECURITY_BRIDGE_SPS] sec
            WHERE 
                sec.Level_3_Reference_ID = @Level_3_Reference_ID
                AND sec.Email_ID = SESSION_CONTEXT(N'user_email')
        );
GO
