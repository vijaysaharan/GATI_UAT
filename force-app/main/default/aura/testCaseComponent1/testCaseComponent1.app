<aura:application extends="ltng:outApp" >
    <lightning:workspaceAPI aura:id="workspace" />
    <aura:attribute name="focusedTabId" type="string"/>
    <c:bulkUpload recordTypeId="012p0000000SfhRAAS" oncloseclicked="{!c.closeFocusedTab}"/>
</aura:application>