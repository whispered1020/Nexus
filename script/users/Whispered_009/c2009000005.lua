--Escort Penguin
local s,id=GetID()
function s.initial_effect(c)
	--If this card is used for the Xyz Summon of a WATER monster, it can be treated as a Level 4 monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.xyzlv)
	c:RegisterEffect(e1)
		--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x5a}
--xyz material level change
function s.xyzlv(e,c,rc)
	local lv=e:GetHandler():GetLevel()
	if rc:IsAttribute(ATTRIBUTE_WATER) then
		return 4,lv
	else
		return lv
	end
end
-- SpecialSummon
function s.cfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WATER)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- Cannot Special Summon monsters, except "WATER" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_REMOVED|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
	end