' ------------------------------------------------------------
' Library Name:      Microsoft Agent Control 2.0
' Library File:      C:\WINNT5\msagent\agentctl.dll
' ------------------------------------------------------------
' Version Info:
' -------------
' Comments:
' Company Name:      Microsoft Corporation
' File Description:  Microsoft Agent Control
' File Version:      2.00.0.3422
' Internal Name:     AgentControl
' Legal Copyright:   Copyright (C) Microsoft Corp. 1997-98
' Legal Trademarks:
' Original Filename: AgentCtl.dll
' Private Build:
' Product Name:      Microsoft Agent Control
' Product Version:   2.00.0.3422
' Special Build:
' ------------------------------------------------------------
' ProgID:            Agent.Control.2
' Interface Prefix:  Agent
' ------------------------------------------------------------

$PROGID_AgentControl2 = "Agent.Control.2"


INTERFACE DISPATCH AgentAgent
    MEMBER GET Characters<&H3>() AS AgentIAgentCtlCharacters
    MEMBER GET AudioOutput<&H4>() AS AgentIAgentCtlAudioObjectEx
    MEMBER GET SpeechInput<&H5>() AS AgentIAgentCtlSpeechInput
    MEMBER GET PropertySheet<&H8>() AS AgentIAgentCtlPropertySheet
    MEMBER GET CommandsWindow<&HC>() AS AgentIAgentCtlCommandsWindow
    MEMBER GET Connected<&H9>() AS LONG
    MEMBER LET Connected<&H9>()   'Parameter Type As Long
    MEMBER GET Suspended<&HE>() AS LONG
    MEMBER CALL ShowDefaultCharacterProperties<&H14>(OPTIONAL IN x AS VARIANT<&H0>, OPTIONAL IN y AS VARIANT<&H1>)
    MEMBER GET RaiseRequestErrors<&H15>() AS LONG
    MEMBER LET RaiseRequestErrors<&H15>()   'Parameter Type As Long
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtl
    MEMBER GET Characters<&H3>() AS AgentIAgentCtlCharacters
    MEMBER GET AudioOutput<&H4>() AS AgentIAgentCtlAudioObjectEx
    MEMBER GET SpeechInput<&H5>() AS AgentIAgentCtlSpeechInput
    MEMBER GET PropertySheet<&H8>() AS AgentIAgentCtlPropertySheet
    MEMBER GET CommandsWindow<&HC>() AS AgentIAgentCtlCommandsWindow
    MEMBER GET Connected<&H9>() AS LONG
    MEMBER LET Connected<&H9>()   'Parameter Type As Long
    MEMBER GET Suspended<&HE>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlAudioObject
    MEMBER GET Enabled<&H1>() AS LONG
    MEMBER GET SoundEffects<&H2>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlAudioObjectEx
    MEMBER GET Enabled<&H1>() AS LONG
    MEMBER GET SoundEffects<&H2>() AS LONG
    MEMBER GET STATUS<&H3>() AS INTEGER
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlBalloon
    MEMBER GET Enabled<&H1>() AS LONG
    MEMBER GET NumberOfLines<&H2>() AS LONG
    MEMBER GET CharsPerLine<&H3>() AS LONG
    MEMBER GET FontName<&H4>() AS STRING
    MEMBER GET FontSize<&H5>() AS LONG
    MEMBER GET FontBold<&HA>() AS LONG
    MEMBER GET FontItalic<&HB>() AS LONG
    MEMBER GET FontStrikethru<&HC>() AS LONG
    MEMBER GET FontUnderline<&HD>() AS LONG
    MEMBER GET ForeColor<&H7>() AS LONG
    MEMBER GET BackColor<&H8>() AS LONG
    MEMBER GET BorderColor<&H9>() AS LONG
    MEMBER LET Visible<&HE>()   'Parameter Type As Long
    MEMBER GET Visible<&HE>() AS LONG
    MEMBER LET FontName<&H4>()   'Parameter Type As String
    MEMBER LET FontSize<&H5>()   'Parameter Type As Long
    MEMBER LET FontCharSet<&HF>()   'Parameter Type As Integer
    MEMBER GET FontCharSet<&HF>() AS INTEGER
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlBalloonEx
    MEMBER GET Enabled<&H1>() AS LONG
    MEMBER GET NumberOfLines<&H2>() AS LONG
    MEMBER GET CharsPerLine<&H3>() AS LONG
    MEMBER GET FontName<&H4>() AS STRING
    MEMBER GET FontSize<&H5>() AS LONG
    MEMBER GET FontBold<&HA>() AS LONG
    MEMBER GET FontItalic<&HB>() AS LONG
    MEMBER GET FontStrikethru<&HC>() AS LONG
    MEMBER GET FontUnderline<&HD>() AS LONG
    MEMBER GET ForeColor<&H7>() AS LONG
    MEMBER GET BackColor<&H8>() AS LONG
    MEMBER GET BorderColor<&H9>() AS LONG
    MEMBER LET Visible<&HE>()   'Parameter Type As Long
    MEMBER GET Visible<&HE>() AS LONG
    MEMBER LET FontName<&H4>()   'Parameter Type As String
    MEMBER LET FontSize<&H5>()   'Parameter Type As Long
    MEMBER LET FontCharSet<&HF>()   'Parameter Type As Integer
    MEMBER GET FontCharSet<&HF>() AS INTEGER
    MEMBER LET Style<&H10>()   'Parameter Type As Long
    MEMBER GET Style<&H10>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCharacter
    MEMBER GET Balloon<&H17>() AS AgentIAgentCtlBalloonEx
    MEMBER GET Commands<&H19>() AS AgentIAgentCtlCommandsEx
    MEMBER GET NAME<&H18>() AS STRING
    MEMBER GET Description<&H1C>() AS STRING
    MEMBER GET Visible<&H2>() AS LONG
    MEMBER LET LEFT<&H3>()   'Parameter Type As Integer
    MEMBER GET LEFT<&H3>() AS INTEGER
    MEMBER LET Top<&H4>()   'Parameter Type As Integer
    MEMBER GET Top<&H4>() AS INTEGER
    MEMBER LET Height<&H5>()   'Parameter Type As Integer
    MEMBER GET Height<&H5>() AS INTEGER
    MEMBER LET WIDTH<&H6>()   'Parameter Type As Integer
    MEMBER GET WIDTH<&H6>() AS INTEGER
    MEMBER GET Speed<&HA>() AS LONG
    MEMBER GET Pitch<&HB>() AS LONG
    MEMBER LET IdleOn<&H1D>()   'Parameter Type As Long
    MEMBER GET IdleOn<&H1D>() AS LONG
    MEMBER CALL Activate<&H1A>(OPTIONAL IN STATE AS VARIANT<&H0>) AS LONG
    MEMBER CALL Play<&HD>(IN Animation AS STRING<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL GET<&H1B>(IN TYPE AS STRING<&H0>, IN NAME AS STRING<&H1>, OPTIONAL IN Queue AS VARIANT<&H2>) AS AgentIAgentCtlRequest
    MEMBER CALL STOP<&HE>(OPTIONAL IN Request AS VARIANT<&H0>)
    MEMBER CALL Wait<&H16>(IN WaitForRequest AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL Interrupt<&H15>(IN InterruptRequest AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL Speak<&HF>(OPTIONAL IN TEXT AS VARIANT<&H0>, OPTIONAL IN Url AS VARIANT<&H1>) AS AgentIAgentCtlRequest
    MEMBER CALL GestureAt<&H11>(IN x AS INTEGER<&H0>, IN y AS INTEGER<&H1>) AS AgentIAgentCtlRequest
    MEMBER CALL MoveTo<&H12>(IN x AS INTEGER<&H0>, IN y AS INTEGER<&H1>, OPTIONAL IN Speed AS VARIANT<&H2>) AS AgentIAgentCtlRequest
    MEMBER CALL Hide<&H13>(OPTIONAL IN Fast AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL SHOW<&H14>(OPTIONAL IN Fast AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL StopAll<&H1F>(OPTIONAL IN Types AS VARIANT<&H0>)
    MEMBER GET MoveCause<&H20>() AS INTEGER
    MEMBER GET VisibilityCause<&H21>() AS INTEGER
    MEMBER GET HasOtherClients<&H22>() AS LONG
    MEMBER LET SoundEffectsOn<&H23>()   'Parameter Type As Long
    MEMBER GET SoundEffectsOn<&H23>() AS LONG
    MEMBER LET NAME<&H18>()   'Parameter Type As String
    MEMBER LET Description<&H1C>()   'Parameter Type As String
    MEMBER GET ExtraData<&H24>() AS STRING
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCharacterEx
    MEMBER GET Balloon<&H17>() AS AgentIAgentCtlBalloonEx
    MEMBER GET Commands<&H19>() AS AgentIAgentCtlCommandsEx
    MEMBER GET NAME<&H18>() AS STRING
    MEMBER GET Description<&H1C>() AS STRING
    MEMBER GET Visible<&H2>() AS LONG
    MEMBER LET LEFT<&H3>()   'Parameter Type As Integer
    MEMBER GET LEFT<&H3>() AS INTEGER
    MEMBER LET Top<&H4>()   'Parameter Type As Integer
    MEMBER GET Top<&H4>() AS INTEGER
    MEMBER LET Height<&H5>()   'Parameter Type As Integer
    MEMBER GET Height<&H5>() AS INTEGER
    MEMBER LET WIDTH<&H6>()   'Parameter Type As Integer
    MEMBER GET WIDTH<&H6>() AS INTEGER
    MEMBER GET Speed<&HA>() AS LONG
    MEMBER GET Pitch<&HB>() AS LONG
    MEMBER LET IdleOn<&H1D>()   'Parameter Type As Long
    MEMBER GET IdleOn<&H1D>() AS LONG
    MEMBER CALL Activate<&H1A>(OPTIONAL IN STATE AS VARIANT<&H0>) AS LONG
    MEMBER CALL Play<&HD>(IN Animation AS STRING<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL GET<&H1B>(IN TYPE AS STRING<&H0>, IN NAME AS STRING<&H1>, OPTIONAL IN Queue AS VARIANT<&H2>) AS AgentIAgentCtlRequest
    MEMBER CALL STOP<&HE>(OPTIONAL IN Request AS VARIANT<&H0>)
    MEMBER CALL Wait<&H16>(IN WaitForRequest AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL Interrupt<&H15>(IN InterruptRequest AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL Speak<&HF>(OPTIONAL IN TEXT AS VARIANT<&H0>, OPTIONAL IN Url AS VARIANT<&H1>) AS AgentIAgentCtlRequest
    MEMBER CALL GestureAt<&H11>(IN x AS INTEGER<&H0>, IN y AS INTEGER<&H1>) AS AgentIAgentCtlRequest
    MEMBER CALL MoveTo<&H12>(IN x AS INTEGER<&H0>, IN y AS INTEGER<&H1>, OPTIONAL IN Speed AS VARIANT<&H2>) AS AgentIAgentCtlRequest
    MEMBER CALL Hide<&H13>(OPTIONAL IN Fast AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL SHOW<&H14>(OPTIONAL IN Fast AS VARIANT<&H0>) AS AgentIAgentCtlRequest
    MEMBER CALL StopAll<&H1F>(OPTIONAL IN Types AS VARIANT<&H0>)
    MEMBER GET MoveCause<&H20>() AS INTEGER
    MEMBER GET VisibilityCause<&H21>() AS INTEGER
    MEMBER GET HasOtherClients<&H22>() AS LONG
    MEMBER LET SoundEffectsOn<&H23>()   'Parameter Type As Long
    MEMBER GET SoundEffectsOn<&H23>() AS LONG
    MEMBER LET NAME<&H18>()   'Parameter Type As String
    MEMBER LET Description<&H1C>()   'Parameter Type As String
    MEMBER GET ExtraData<&H24>() AS STRING
    MEMBER CALL ShowPopupMenu<&H25>(IN x AS INTEGER<&H0>, IN y AS INTEGER<&H1>) AS LONG
    MEMBER LET AutoPopupMenu<&H26>()   'Parameter Type As Long
    MEMBER GET AutoPopupMenu<&H26>() AS LONG
    MEMBER LET HelpModeOn<&H27>()   'Parameter Type As Long
    MEMBER GET HelpModeOn<&H27>() AS LONG
    MEMBER LET HelpContextID<&H28>()   'Parameter Type As Long
    MEMBER GET HelpContextID<&H28>() AS LONG
    MEMBER GET Active<&H29>() AS INTEGER
    MEMBER CALL Listen<&H2A>(IN Listen AS LONG<&H0>) AS LONG
    MEMBER LET LanguageID<&H2B>()   'Parameter Type As Long
    MEMBER GET LanguageID<&H2B>() AS LONG
    MEMBER GET SRModeID<&H2E>() AS STRING
    MEMBER LET SRModeID<&H2E>()   'Parameter Type As String
    MEMBER GET TTSModeID<&H2F>() AS STRING
    MEMBER LET TTSModeID<&H2F>()   'Parameter Type As String
    MEMBER GET HelpFile<&H30>() AS STRING
    MEMBER LET HelpFile<&H30>()   'Parameter Type As String
    MEMBER GET GUID<&H31>() AS STRING
    MEMBER GET OriginalHeight<&H32>() AS INTEGER
    MEMBER GET OriginalWidth<&H33>() AS INTEGER
    MEMBER CALL Think<&H34>(IN TEXT AS STRING<&H0>) AS AgentIAgentCtlRequest
    MEMBER GET Version<&H35>() AS STRING
    MEMBER GET AnimationNames<&H36>() AS AgentIAgentCtlAnimationNames
    MEMBER GET SRStatus<&H37>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCharacters
    MEMBER GET Item<&H0>(IN CharacterID AS STRING<&H0>) AS AgentIAgentCtlCharacterEx
    MEMBER CALL Character<&H3>(IN CharacterID AS STRING<&H0>) AS AgentIAgentCtlCharacterEx
    MEMBER CALL Unload<&H2>(IN CharacterID AS STRING<&H0>)
    MEMBER CALL Load<&H1>(IN CharacterID AS STRING<&H0>, OPTIONAL IN LoadKey AS VARIANT<&H1>) AS AgentIAgentCtlRequest
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCommand
    MEMBER GET Voice<&H1>() AS STRING
    MEMBER LET Voice<&H1>()   'Parameter Type As String
    MEMBER GET Caption<&H2>() AS STRING
    MEMBER LET Caption<&H2>()   'Parameter Type As String
    MEMBER GET Enabled<&H5>() AS LONG
    MEMBER LET Enabled<&H5>()   'Parameter Type As Long
    MEMBER GET Visible<&H6>() AS LONG
    MEMBER LET Visible<&H6>()   'Parameter Type As Long
    MEMBER GET Confidence<&H3>() AS LONG
    MEMBER LET Confidence<&H3>()   'Parameter Type As Long
    MEMBER GET ConfidenceText<&H4>() AS STRING
    MEMBER LET ConfidenceText<&H4>()   'Parameter Type As String
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCommandEx
    MEMBER GET Voice<&H1>() AS STRING
    MEMBER LET Voice<&H1>()   'Parameter Type As String
    MEMBER GET Caption<&H2>() AS STRING
    MEMBER LET Caption<&H2>()   'Parameter Type As String
    MEMBER GET Enabled<&H5>() AS LONG
    MEMBER LET Enabled<&H5>()   'Parameter Type As Long
    MEMBER GET Visible<&H6>() AS LONG
    MEMBER LET Visible<&H6>()   'Parameter Type As Long
    MEMBER GET Confidence<&H3>() AS LONG
    MEMBER LET Confidence<&H3>()   'Parameter Type As Long
    MEMBER GET ConfidenceText<&H4>() AS STRING
    MEMBER LET ConfidenceText<&H4>()   'Parameter Type As String
    MEMBER LET HelpContextID<&H7>()   'Parameter Type As Long
    MEMBER GET HelpContextID<&H7>() AS LONG
    MEMBER LET VoiceCaption<&H8>()   'Parameter Type As String
    MEMBER GET VoiceCaption<&H8>() AS STRING
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCommands
    MEMBER GET Item<&H0>(IN NAME AS STRING<&H0>) AS AgentIAgentCtlCommandEx
    MEMBER CALL Command<&HF>(IN NAME AS STRING<&H0>) AS AgentIAgentCtlCommandEx
    MEMBER GET Count<&H2>() AS LONG
    MEMBER GET Caption<&H3>() AS STRING
    MEMBER LET Caption<&H3>()   'Parameter Type As String
    MEMBER GET Voice<&H4>() AS STRING
    MEMBER LET Voice<&H4>()   'Parameter Type As String
    MEMBER GET Visible<&H5>() AS LONG
    MEMBER LET Visible<&H5>()   'Parameter Type As Long
    MEMBER CALL ADD<&HA>(IN NAME AS STRING<&H0>, OPTIONAL IN Caption AS VARIANT<&H1>, OPTIONAL IN Voice AS VARIANT<&H2>, OPTIONAL IN Enabled AS VARIANT<&H3>, OPTIONAL IN Visible AS VARIANT<&H4>) AS AgentIAgentCtlCommand
    MEMBER CALL INSERT<&HB>(IN NAME AS STRING<&H0>, IN RefName AS STRING<&H1>, OPTIONAL IN Before AS VARIANT<&H2>, OPTIONAL IN Caption AS VARIANT<&H3>, OPTIONAL IN Voice AS VARIANT<&H4>, OPTIONAL IN Enabled AS VARIANT<&H5>, _
        OPTIONAL IN Visible AS VARIANT<&H6>) AS AgentIAgentCtlCommand
    MEMBER CALL Remove<&HD>(IN NAME AS STRING<&H0>)
    MEMBER CALL RemoveAll<&HE>()
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCommandsEx
    MEMBER GET Item<&H0>(IN NAME AS STRING<&H0>) AS AgentIAgentCtlCommandEx
    MEMBER CALL Command<&HF>(IN NAME AS STRING<&H0>) AS AgentIAgentCtlCommandEx
    MEMBER GET Count<&H2>() AS LONG
    MEMBER GET Caption<&H3>() AS STRING
    MEMBER LET Caption<&H3>()   'Parameter Type As String
    MEMBER GET Voice<&H4>() AS STRING
    MEMBER LET Voice<&H4>()   'Parameter Type As String
    MEMBER GET Visible<&H5>() AS LONG
    MEMBER LET Visible<&H5>()   'Parameter Type As Long
    MEMBER CALL ADD<&HA>(IN NAME AS STRING<&H0>, OPTIONAL IN Caption AS VARIANT<&H1>, OPTIONAL IN Voice AS VARIANT<&H2>, OPTIONAL IN Enabled AS VARIANT<&H3>, OPTIONAL IN Visible AS VARIANT<&H4>) AS AgentIAgentCtlCommand
    MEMBER CALL INSERT<&HB>(IN NAME AS STRING<&H0>, IN RefName AS STRING<&H1>, OPTIONAL IN Before AS VARIANT<&H2>, OPTIONAL IN Caption AS VARIANT<&H3>, OPTIONAL IN Voice AS VARIANT<&H4>, OPTIONAL IN Enabled AS VARIANT<&H5>, _
        OPTIONAL IN Visible AS VARIANT<&H6>) AS AgentIAgentCtlCommand
    MEMBER CALL Remove<&HD>(IN NAME AS STRING<&H0>)
    MEMBER CALL RemoveAll<&HE>()
    MEMBER LET DefaultCommand<&H10>()   'Parameter Type As String
    MEMBER GET DefaultCommand<&H10>() AS STRING
    MEMBER LET HelpContextID<&H11>()   'Parameter Type As Long
    MEMBER GET HelpContextID<&H11>() AS LONG
    MEMBER LET FontName<&H15>()   'Parameter Type As String
    MEMBER GET FontName<&H15>() AS STRING
    MEMBER GET FontSize<&H17>() AS LONG
    MEMBER LET FontSize<&H17>()   'Parameter Type As Long
    MEMBER LET VoiceCaption<&H16>()   'Parameter Type As String
    MEMBER GET VoiceCaption<&H16>() AS STRING
    MEMBER LET GlobalVoiceCommandsEnabled<&H18>()   'Parameter Type As Long
    MEMBER GET GlobalVoiceCommandsEnabled<&H18>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlCommandsWindow
    MEMBER GET Visible<&H5>() AS LONG
    MEMBER LET Visible<&H5>()   'Parameter Type As Long
    MEMBER GET LEFT<&H6>() AS INTEGER
    MEMBER GET Top<&H7>() AS INTEGER
    MEMBER GET Height<&H8>() AS INTEGER
    MEMBER GET WIDTH<&H9>() AS INTEGER
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlEx
    MEMBER GET Characters<&H3>() AS AgentIAgentCtlCharacters
    MEMBER GET AudioOutput<&H4>() AS AgentIAgentCtlAudioObjectEx
    MEMBER GET SpeechInput<&H5>() AS AgentIAgentCtlSpeechInput
    MEMBER GET PropertySheet<&H8>() AS AgentIAgentCtlPropertySheet
    MEMBER GET CommandsWindow<&HC>() AS AgentIAgentCtlCommandsWindow
    MEMBER GET Connected<&H9>() AS LONG
    MEMBER LET Connected<&H9>()   'Parameter Type As Long
    MEMBER GET Suspended<&HE>() AS LONG
    MEMBER CALL ShowDefaultCharacterProperties<&H14>(OPTIONAL IN x AS VARIANT<&H0>, OPTIONAL IN y AS VARIANT<&H1>)
    MEMBER GET RaiseRequestErrors<&H15>() AS LONG
    MEMBER LET RaiseRequestErrors<&H15>()   'Parameter Type As Long
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlPropertySheet
    MEMBER GET LEFT<&H1>() AS INTEGER
    MEMBER GET Top<&H2>() AS INTEGER
    MEMBER GET Height<&H3>() AS INTEGER
    MEMBER GET WIDTH<&H4>() AS INTEGER
    MEMBER LET Visible<&H6>()   'Parameter Type As Long
    MEMBER GET Visible<&H6>() AS LONG
    MEMBER LET Page<&H5>()   'Parameter Type As String
    MEMBER GET Page<&H5>() AS STRING
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlRequest
    MEMBER GET STATUS<&H1>() AS LONG
    MEMBER GET Description<&H2>() AS STRING
    MEMBER GET Number<&H3>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlSpeechInput
    MEMBER GET Enabled<&H1>() AS LONG
    MEMBER GET Language<&H2>() AS STRING
    MEMBER GET HotKey<&H3>() AS STRING
    MEMBER GET Installed<&H4>() AS LONG
    MEMBER GET Engine<&H5>() AS STRING
    MEMBER LET Engine<&H5>()   'Parameter Type As String
    MEMBER GET ListeningTip<&H6>() AS LONG
END INTERFACE

INTERFACE DISPATCH AgentIAgentCtlUserInput
    MEMBER GET Count<&H60020000>() AS INTEGER
    MEMBER GET NAME<&H60020001>() AS STRING
    MEMBER GET CharacterID<&H60020002>() AS STRING
    MEMBER GET Confidence<&H60020003>() AS LONG
    MEMBER GET Voice<&H60020004>() AS STRING
    MEMBER GET Alt1Name<&H60020005>() AS STRING
    MEMBER GET Alt1Confidence<&H60020006>() AS LONG
    MEMBER GET Alt1Voice<&H60020007>() AS STRING
    MEMBER GET Alt2Name<&H60020008>() AS STRING
    MEMBER GET Alt2Confidence<&H60020009>() AS LONG
    MEMBER GET Alt2Voice<&H6002000A>() AS STRING
END INTERFACE
