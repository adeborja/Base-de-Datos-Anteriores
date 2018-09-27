USE [Becas]
GO
SET IDENTITY_INSERT [dbo].[Alumnos] ON 

GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (1, N'David Abraham', N'Aguilar Martín', 1, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (3, N'Carlos', N'Alberto Vadillo', 1, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (4, N'Manuel', N'Bancalero Carretero', 1, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (5, N'Yeray Manuel', N'Campanario Fernández', 1, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (6, N'Francisco Javier', N'Carmona Romero', 2, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (7, N'Iván', N'Castillo Calle', 2, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (8, N'Pablo', N'Chacón García', 2, NULL)
GO
INSERT [dbo].[Alumnos] ([idAlumno], [nombreAlumno], [apellidosAlumno], [idCurso], [beca]) VALUES (9, N'Alejandro', N'Gómez Olivera', 2, NULL)
GO
SET IDENTITY_INSERT [dbo].[Alumnos] OFF
GO
SET IDENTITY_INSERT [dbo].[Cursos] ON 

GO
INSERT [dbo].[Cursos] ([idCurso], [nombreCurso]) VALUES (1, N'1º CFGS')
GO
INSERT [dbo].[Cursos] ([idCurso], [nombreCurso]) VALUES (2, N'2º CFGS')
GO
SET IDENTITY_INSERT [dbo].[Cursos] OFF
GO
