BeginPackage["Notebook`DemosArchive`", {
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Misc`Events`"
}];

Begin["`Internal`"]


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

End[]
EndPackage[]