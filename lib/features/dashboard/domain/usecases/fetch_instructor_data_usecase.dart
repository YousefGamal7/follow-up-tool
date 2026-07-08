import '../entities/instructor_data_entity.dart';
import '../repositories/dashboard_repository.dart';

class FetchInstructorDataUseCase {
  final DashboardRepository repository;

  FetchInstructorDataUseCase(this.repository);

  Future<InstructorDataEntity?> call(String instructorName, String? selectedAssignment) {
    return repository.fetchInstructorData(instructorName, selectedAssignment);
  }
}
