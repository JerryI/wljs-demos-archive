BeginPackage["Notebook`DemosArchive`", {
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Misc`Events`",
    "JerryI`WLX`WebUI`"
}];

Begin["`Internal`"]


<|"Client"->$Client, "Settings"->settings, "Env"->env|>

checkReleaseNotes[assoc_] := With[{client = assoc["Client"], settings = assoc["Settings"], env = assoc["Env"]}, If[env["AppJSON", "version"] =!= settings["CurrentVersion"], With[{version = env["AppJSON", "version"]},
  With[{files = FileNames["*.wln", FileNameJoin[{AppExtensions`DemosDir (*`*), "Release notes"}] ]},
    With[{
        books = If[StringQ[settings["CurrentVersion"]], 
          Select[files, Function[name, StringMatchQ[FileNameTake[name], version~~__] ] ]
        ,
          {Last[SortBy[files, FileDate] ]}
        ]
      },
      Echo[StringJoin["Checking release notes for ", version] ];
      Echo[books];
      If[Length[books] > 0,
        WebUILocation[StringJoin["/", URLEncode[books[[1]] ] ], client, "Target"->_];
      ];

    
      
    ];

    ClearAll[checkReleaseNotes];
  ]
] ] ];


MergeDirectories[source_String, target_String] := (
  Echo[StringTemplate["Copy directory `` to ``"][source, target]];
  If[!DirectoryQ[target], CreateDirectory[target]; ];
  
  With[{names = FileNames[All, source]},
    With[{folders = Select[names, DirectoryQ[#] &], files = Select[names, !DirectoryQ[#] &]},

    
      Map[Function[folder,
        With[{folderName = FileNameTake[folder, -1] },
          MergeDirectories[folder, FileNameJoin[{target, folderName}]]
        ]], folders];

      Map[Function[file,
        CopyFile[file, FileNameJoin[{target, FileNameTake[file, -1]}], OverwriteTarget->True];
        Echo[StringTemplate["Copied `` to ``"][file, FileNameJoin[{target, FileNameTake[file, -1]}]]];
      ], files];
    ]
  ];
);

root = $InputFileName // DirectoryName;

If[FileExistsQ[FileNameJoin @ {root, ".nosync"}],
  Echo["Syncing demo folders..."];

  MergeDirectories[FileNameJoin[{root, "Demos"}], AppExtensions`DemosDir]; 
  DeleteFile[FileNameJoin @ {root, ".nosync"}];
  (*DeleteDirectory[FileNameJoin @ {root, "Demos"}]*)
]


EventHandler[EventClone[AppExtensions`AppEvent], {
    "AfterUILoad" -> checkReleaseNotes
}];


End[]
EndPackage[]