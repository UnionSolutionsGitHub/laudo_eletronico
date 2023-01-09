import 'package:laudo_eletronico/infrastructure/dal/dao/answer_attachment_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/answer_dao.dart';
import 'package:laudo_eletronico/infrastructure/dal/dao/laudo_dao.dart';
import 'package:laudo_eletronico/infrastructure/resources/file_manager.dart';
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';
import 'package:laudo_eletronico/infrastructure/services/union_solutions/union_solution_service.dart';
import 'package:laudo_eletronico/model/configuration.dart';
import 'package:laudo_eletronico/model/laudo.dart';
import 'package:laudo_eletronico/model/user.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';

class LocalResourcesMock extends Mock implements LocalResources {}
class PackageInfoMock extends Mock implements PackageInfo {}
class UserMock extends Mock implements User {}
class UnionSolutionsServiceMock extends Mock implements UnionSolutionsService {}
class FileManagerMock extends Mock implements FileManager {}
class LaudoDAOMock extends Mock implements LaudoDAO {}
class AnswerDAOMock extends Mock implements AnswerDAO {}
class AnswerAttachmentDAOMock extends Mock implements AnswerAttachmentDAO {}
class LaudoMock extends Mock implements Laudo {}
class ConfigurationMock extends Mock implements Configuration {}
